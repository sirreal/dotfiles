local log = require("plugins.utils").log

local ok, null_ls = pcall(require, "null-ls")
if not ok then
	log.error("could not load null_ls")
	return
end

local tsserver_fts = require("lspconfig").tsserver.filetypes
local helpers = require("null-ls.helpers")

local get_offset_positions = function(content, start_offset, end_offset)
	-- ESLint uses character offsets, so convert to byte indexes to handle multibyte characters
	local to_string = table.concat(content, "\n")
	start_offset = vim.str_byteindex(to_string, start_offset + 1)
	end_offset = vim.str_byteindex(to_string, end_offset + 1)
	-- save original window position and virtualedit setting
	local view = vim.fn.winsaveview()
	local virtualedit = vim.opt.virtualedit
	vim.opt.virtualedit = "all"
	vim.cmd("go " .. start_offset)
	-- (1,0)-indexed
	local cursor = vim.api.nvim_win_get_cursor(0)
	local col = cursor[2] + 1
	vim.cmd("go " .. end_offset)
	cursor = vim.api.nvim_win_get_cursor(0)
	local end_row, end_col = cursor[1], cursor[2] + 1
	-- restore state
	vim.fn.winrestview(view)
	vim.opt.virtualedit = virtualedit
	return col, end_col, end_row
end

local function read_line(line, bufnr)
	return vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
end

local function get_fix_range(problem, params)
	-- 1-indexed
	local row = problem.line
	local offset = problem.fix.range[1]
	local end_offset = problem.fix.range[2]
	local col, end_col, end_row = get_offset_positions(params.content, offset, end_offset)
	return { row = row, col = col, end_row = end_row, end_col = end_col }
end

local function generate_edit_action(title, new_text, range, params)
	return {
		title = title,
		action = function()
			-- 0-indexed
			vim.api.nvim_buf_set_text(
				params.bufnr,
				range.row - 1,
				range.col - 1,
				range.end_row - 1,
				range.end_col - 1,
				vim.split(new_text, "\n")
			)
		end,
	}
end

local function generate_edit_line_action(title, new_text, row, params)
	return {
		title = title,
		action = function()
			-- 0-indexed
			vim.api.nvim_buf_set_lines(params.bufnr, row - 1, row - 1, false, { new_text })
		end,
	}
end

local range_includes_row = function(message, row)
	if not message or not message.line then
		return false
	end

	if message.endline then
		return message.line <= row and message.endLine >= row
	end

	return message.line == row
end

local generate_suggestion_action = function(suggestion, message, params)
	local title = suggestion.desc
	local new_text = suggestion.fix.text
	local range = get_message_range(message)
	return generate_edit_action(title, new_text, range, params)
end

local generate_fix_actions = function(message, indentation, params)
	local actions = {}

	if message.fix then
		local title = "[FIX] ESLint: " .. message.message
		local new_text = message.fix.text
		local range = get_fix_range(message, params)
		table.insert(actions, generate_edit_action(title, new_text, range, params))
	end

	if message.suggestions then
		for _, suggestion in ipairs(message.suggestions) do
			local title = "[FIX] ESLint: " .. suggestion.desc
			local new_text = suggestion.fix.text
			local range = get_fix_range({ line = message.line, fix = suggestion.fix }, params)
			table.insert(actions, generate_edit_action(title, new_text, range, params))
		end
	end

	return actions
end

local function escape_string_pattern(s)
	return s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
end

local eslint_disable_line_prefix = "// eslint-disable-next-line "
local eslint_disable_prefix = "/* eslint-disable "
local generate_disable_actions = function(message, indentation, params)
	local rule_id = message.ruleId
	local row = params.row

	if not rule_id then
		return {}
	end

	local actions = {}

	--
	-- Disable for line
	--
	local line_title = "[DISABLE] ESLint: " .. rule_id .. " for line"
	local previous_line = read_line(message.line - 2) -- buffer is 0-indexed, eslint message 1-indexed
	local disable_line_action
	if previous_line:match("^%s*" .. escape_string_pattern(eslint_disable_line_prefix)) then
		local line_text = previous_line .. ", " .. rule_id
		disable_line_action = {
			title = line_title,
			action = function()
				vim.api.nvim_buf_set_lines(params.bufnr, row - 2, row - 1, false, { line_text })
			end,
		}
	else
		local line_text = indentation .. eslint_disable_line_prefix .. rule_id
		disable_line_action = {
			title = line_title,
			action = function()
				vim.api.nvim_buf_set_lines(params.bufnr, row - 1, row - 1, false, { line_text })
			end,
		}
	end
	table.insert(actions, disable_line_action)

	--
	-- Disable entire file
	--
	local file_title = "[DISABLE] ESLint: " .. rule_id .. " for the entire file"
	local first_line = read_line(0)
	if first_line:match("^" .. escape_string_pattern(eslint_disable_prefix)) then
		local line_text = first_line:gsub("%s*%*/$", ", " .. rule_id .. " */")
		disable_action = {
			title = file_title,
			action = function()
				vim.api.nvim_buf_set_lines(params.bufnr, 0, 1, false, { line_text })
			end,
		}
	else
		local line_text = eslint_disable_prefix .. rule_id .. " */"
		disable_action = {
			title = file_title,
			action = function()
				vim.api.nvim_buf_set_lines(params.bufnr, 0, 0, false, { line_text })
			end,
		}
	end
	table.insert(actions, disable_action)

	return actions
end

local function generate_actions(messages, indentation, params)
	local actions = {}

	local observed_rules = {}
	for _, message in ipairs(messages) do
		vim.list_extend(actions, generate_fix_actions(message, indentation, params))

		if message.ruleId and not observed_rules[message.ruleId] then
			vim.list_extend(actions, generate_disable_actions(message, indentation, params))
			observed_rules[message.ruleId] = true
		end
	end

	return actions
end

local code_action_handler = function(params)
	local row = params.row
	local indentation = params.content[row]:match("^%s+") or ""

	local problems_in_range = {}
	for _, problem in ipairs(params.messages) do
		if range_includes_row(problem, row) then
			table.insert(problems_in_range, problem)
		end
	end

	return generate_actions(problems_in_range, indentation, params)
end

local on_output = function(params)
	params.messages = params.output and params.output[1] and params.output[1].messages or {}

	local ok, result = pcall(code_action_handler, params)
	if not ok then
		log.error(result)
		return {}
	else
		return result
	end
end

-- From https://github.com/jose-elias-alvarez/null-ls.nvim/blob/da8bb757c630b96fd26030df56fd3a070fbf16a1/lua/null-ls/builtins/diagnostics.lua#L224-L241
local handle_eslint_output = function(params)
	params.messages = params.output and params.output[1] and params.output[1].messages or {}
	if params.err then
		table.insert(params.messages, { message = params.err })
	end
	local parser = helpers.diagnostics.from_json({
		attributes = {
			severity = "severity",
		},
		severities = {
			helpers.diagnostics.severities["warning"],
			helpers.diagnostics.severities["error"],
		},
	})
	return parser({ output = params.messages })
end

local eslint_diagnostics_source = {
	name = "jons-eslint-diagnostics",
	method = null_ls.methods.DIAGNOSTICS,
	filetypes = tsserver_fts,
	generator = helpers.generator_factory({
		command = "eslint_d",
		args = { "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
		to_stdin = true,
		format = "json_raw",
		check_exit_code = function(code)
			return code <= 1
		end,
		use_cache = false,
		on_output = handle_eslint_output,
	}),
}

local eslint_code_action_source = {
	name = "jons-eslint-code-action",
	method = null_ls.methods.CODE_ACTION,
	filetypes = tsserver_fts,
	generator = helpers.generator_factory({
		command = "eslint_d",
		args = { "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
		to_stdin = true,
		format = "json_raw",
		check_exit_code = function(code)
			return code <= 1
		end,
		use_cache = false,
		on_output = on_output,
	}),
}

null_ls.config({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier,
		eslint_diagnostics_source,
		eslint_code_action_source,
	},
})

require("lspconfig")["null-ls"].setup({
	on_attach = require("plugins.utils").on_attach,
})
