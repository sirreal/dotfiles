local helpers = require("null-ls.helpers")

local M = {}

local function range_includes_row(message, row)
	if not message or not message.line then
		return false
	end
	if message.endline then
		return message.line <= row and message.endLine >= row
	end
	return message.line == row
end

local function get_offset_positions(content, window, start_offset, end_offset)
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
	local cursor_start = vim.api.nvim_win_get_cursor(window)
	vim.cmd("go " .. end_offset)
	local cursor_end = vim.api.nvim_win_get_cursor(window)

	-- restore state
	vim.fn.winrestview(view)
	vim.opt.virtualedit = virtualedit
	local col = cursor_start[2] + 1
	local end_row, end_col = cursor_end[1], cursor_end[2] + 1
	return col, end_col, end_row
end

local function get_fix_range(problem, params)
	-- 1-indexed
	local row = problem.line
	local offset = problem.fix.range[1]
	local end_offset = problem.fix.range[2]
	local col, end_col, end_row = get_offset_positions(params.content, params.window, offset, end_offset)
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

local function generate_fix_actions(message, params)
	local actions = {}
	if message.fix then
		local title = message.message .. " (" .. message.ruleId .. ")"
		local new_text = message.fix.text
		local range = get_fix_range(message, params)
		table.insert(actions, generate_edit_action(title, new_text, range, params))
	end
	if message.suggestions then
		for _, suggestion in ipairs(message.suggestions) do
			local title = suggestion.desc .. " (" .. message.ruleId .. ")"

			local new_text = suggestion.fix.text
			local range = get_fix_range({ line = message.line, fix = suggestion.fix }, params)
			table.insert(actions, generate_edit_action(title, new_text, range, params))
		end
	end
	return actions
end

local function read_line(line, bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)
	return lines and lines[1]
end

local function escape_string_pattern(s)
	return s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
end

local eslint_disable_line_prefix = "// eslint-disable-next-line "
local eslint_disable_prefix = "/* eslint-disable "

local function generate_disable_actions(message, indentation, params)
	local rule_id = message.ruleId
	local row = params.row

	if not rule_id then
		return {}
	end

	local actions = {}

	--
	-- Disable for line
	--
	local line_title = "Disable " .. rule_id .. " for this line"
	local previous_line = read_line(message.line - 2, params.bufnr) -- buffer is 0-indexed, eslint message 1-indexed
	local disable_line_action
	if previous_line and previous_line:match("^%s*" .. escape_string_pattern(eslint_disable_line_prefix)) then
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
	local file_title = "Disable " .. rule_id .. " for the entire file"
	local first_line = read_line(0, params.bufnr)
	local disable_action
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
		vim.list_extend(actions, generate_fix_actions(message, params))
		if message.ruleId and not observed_rules[message.ruleId] then
			vim.list_extend(actions, generate_disable_actions(message, indentation, params))
			observed_rules[message.ruleId] = true
		end
	end
	return actions
end

-- From https://github.com/jose-elias-alvarez/null-ls.nvim/blob/da8bb757c630b96fd26030df56fd3a070fbf16a1/lua/null-ls/builtins/diagnostics.lua#L224-L241
M.handle_eslint_output = function(params)
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

M.code_action_handler = function(params)
	params.messages = params.output and params.output[1] and params.output[1].messages or {}

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

return M
