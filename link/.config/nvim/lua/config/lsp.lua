local on_attach = require("config.utils").on_attach

require("lspconfig").tsserver.setup({
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
		vim.api.nvim_command [[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]]
		vim.api.nvim_command [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]]
		vim.api.nvim_command [[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]]
		on_attach(client)
	end,
})

require("lspconfig").rust_analyzer.setup({
	on_attach = on_attach,
})
