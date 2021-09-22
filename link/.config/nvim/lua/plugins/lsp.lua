---@diagnostic disable-next-line: unused-local
local log = require("sirreal.log")
local on_attach = require("plugins.utils").on_attach

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- See https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
local ignored_ts_diagnostic_codes = {
	[80001] = true, -- "File is a CommonJS module; it may be converted to an ES6 module."
}
require("lspconfig").tsserver.setup({
	capabilities = capabilities,
	handlers = {
		["textDocument/publishDiagnostics"] = function(_, _, params, client_id, _, config)
			if params.diagnostics ~= nil then
				local idx = 1
				while idx <= #params.diagnostics do
					if ignored_ts_diagnostic_codes[params.diagnostics[idx].code] then
						table.remove(params.diagnostics, idx)
					else
						idx = idx + 1
					end
				end
			end
			vim.lsp.diagnostic.on_publish_diagnostics(_, _, params, client_id, _, config)
		end,
	},
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
		vim.api.nvim_command([[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]])
		vim.api.nvim_command([[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]])
		vim.api.nvim_command([[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]])
		on_attach(client)
	end,
})

require("lspconfig").rust_analyzer.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

local sumneko_root_path = vim.fn.getenv("HOME") .. "/jon/lua-language-server"
local sumneko_binary = sumneko_root_path .. "/bin/macOS/lua-language-server"

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require("lspconfig").sumneko_lua.setup({
	cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Setup your lua path
				path = runtime_path,
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})
