local on_attach = require("plugins.utils").on_attach

require("lspconfig").tsserver.setup({
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
		vim.api.nvim_command([[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]])
		vim.api.nvim_command([[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]])
		vim.api.nvim_command([[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]])
		on_attach(client)
	end,
})

require("lspconfig").rust_analyzer.setup({
	on_attach = on_attach,
})

-- local runtime_path = vim.split(package.path, ";")
-- table.insert(runtime_path, "lua/?.lua")
-- table.insert(runtime_path, "lua/?/init.lua")

-- require("lspconfig").sumneko_lua.setup({
-- 	on_attach = on_attach,
-- 	cmd = { "lua-language-server", "-E", "--logpath=" .. vim.fn.stdpath("cache") .. "lua-language-server.log" },
-- 	settings = {
-- 		Lua = {
-- 			runtime = {
-- 				version = "LuaJIT",
-- 				path = runtime_path,
-- 			},
-- 			diagnostics = {
-- 				-- Get the language server to recognize the `vim` global
-- 				globals = { "vim" },
-- 			},
-- 			workspace = {
-- 				-- Make the server aware of Neovim runtime files
-- 				library = vim.api.nvim_get_runtime_file("", true),
-- 			},
-- 			telemetry = {
-- 				enable = false,
-- 			},
-- 		},
-- 	},
-- })

-- require("lspconfig").psalm.setup({
-- 	debug = true,
-- 	on_attach = function(a, b)
-- 		vim.lsp.set_log_level("debug")

-- 		print(vim.cmd("e" .. vim.lsp.get_log_path()))

-- 		on_attach(a, b)
-- 	end,
-- })
