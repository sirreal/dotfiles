local null_ls = require("null-ls")

null_ls.config({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.diagnostics.eslint_d,
	},
})
require("lspconfig")["null-ls"].setup({
	on_attach = require("plugins.utils").on_attach,
})
