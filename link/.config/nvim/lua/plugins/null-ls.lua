local log = require("plugins.utils").log

local ok, null_ls = pcall(require, "null-ls")
if not ok then
	log.error("could not load null_ls")
	return
end

local eslint = require("plugins.eslint")
local helpers = require("null-ls.helpers")

local tsserver_filetypes
ok, tsserver_filetypes = pcall(function()
	return require("lspconfig").tsserver.document_config.default_config.filetypes
end)
if not ok then
	log.warn("could not load tsserver filetypes")
	tsserver_filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	}
end

local eslint_diagnostics_source = {
	name = "jons-eslint-diagnostics",
	method = null_ls.methods.DIAGNOSTICS,
	filetypes = tsserver_filetypes,
	generator = helpers.generator_factory({
		command = "eslint_d",
		args = { "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
		to_stdin = true,
		format = "json_raw",
		check_exit_code = function(code)
			return code <= 1
		end,
		use_cache = false,
		on_output = eslint.handle_eslint_output,
	}),
}

local eslint_code_action_source = {
	name = "jons-eslint-code-action",
	method = null_ls.methods.CODE_ACTION,
	filetypes = tsserver_filetypes,
	generator = helpers.generator_factory({
		command = "eslint_d",
		args = { "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
		to_stdin = true,
		format = "json_raw",
		check_exit_code = function(code)
			return code <= 1
		end,
		use_cache = false,
		on_output = function(params)
			local win = vim.api.nvim_get_current_win()
			params.win = win
			return eslint.code_action_handler(params)
		end,
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
