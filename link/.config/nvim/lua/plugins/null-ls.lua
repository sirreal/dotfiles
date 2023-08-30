local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		-- null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.dprint.with({
			extra_filetypes = {
				"css",
				"dockerfile",
				"json5",
				"jsonc",
				"sass",
				"scss",
			},
		}),
		null_ls.builtins.diagnostics.stylelint,
		-- null_ls.builtins.formatting.stylelint,
		null_ls.builtins.diagnostics.eslint_d,
		null_ls.builtins.code_actions.eslint_d,
	},
	on_attach = require("plugins.lsp-attach"),
})
