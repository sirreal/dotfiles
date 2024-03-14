local cmd_resolver = require("null-ls.helpers.command_resolver")
local null_ls = require("null-ls")
local util = require("null-ls.utils")

local from_composer_vendor = function()
	local resolver = cmd_resolver.generic(util.path.join("vendor", "bin"))
	return function(params)
		return resolver(params) or params.command
	end
end

null_ls.setup({
	sources = {
		null_ls.builtins.diagnostics.phpcs.with({
			dynamic_command = from_composer_vendor(),
		}),
		null_ls.builtins.diagnostics.stylelint,

		null_ls.builtins.formatting.phpcbf.with({
			dynamic_command = from_composer_vendor(),
		}),
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylua,

		-- Not using dprint now
		-- null_ls.builtins.formatting.dprint.with({
		-- 	extra_filetypes = {
		-- 		"css",
		-- 		"dockerfile",
		-- 		"json5",
		-- 		"jsonc",
		-- 		"sass",
		-- 		"scss",
		-- 	},
		-- }),
	},
	on_attach = require("plugins.lsp-attach"),
})
