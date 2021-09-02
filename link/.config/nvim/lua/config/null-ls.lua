local null_ls = require("null-ls")

null_ls.config({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.diagnostics.eslint.with({
			command = "yarn",
			args = { "eslint", "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
		}),
	},
})
require("lspconfig")["null-ls"].setup({
	on_attach = require("config.utils").on_attach,
})
