local on_attach = require("config.utils").on_attach

require("lspconfig").tsserver.setup({
	on_attach = function(client)
		client.resolved_capabilities_document_formatting = false
		on_attach(client)
	end,
})

require("lspconfig").rust_analyzer.setup({
	on_attach = on_attach,
})
