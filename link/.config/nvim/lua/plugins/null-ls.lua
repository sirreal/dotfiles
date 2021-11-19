local log = require("sirreal.log")

local ok, null_ls = pcall(require, "null-ls")
if not ok then
	log.error("could not load null_ls")
	return
end

null_ls.config({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.diagnostics.stylelint,
		null_ls.builtins.formatting.stylelint,
		null_ls.builtins.diagnostics.eslint_d,
		null_ls.builtins.code_actions.eslint_d,
	},
})

require("lspconfig")["null-ls"].setup({
	on_attach = require("plugins.lsp-attach"),
})
