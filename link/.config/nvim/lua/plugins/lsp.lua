local on_attach = require("plugins.lsp-attach")

local signs = {
	Error = "",
	Warn = "",
	Hint = "󰋼",
	Info = "󰋼",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
})

local on_publish_diagnostics = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = {
		prefix = "",
		spacing = 0,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})
vim.lsp.handlers["textDocument/publishDiagnostics"] = on_publish_diagnostics

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- See https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
local ignored_ts_diagnostic_codes = {
	[80001] = true, -- "File is a CommonJS module; it may be converted to an ES6 module."
}

-- requires npm:vscode-langservers-extracted
require("lspconfig").jsonls.setup({
	capabilities = capabilities,
	filetypes = { "json", "jsonc", "json5" },
	init_options = {
		provideFormatter = false,
	},
	handlers = {
		["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
			-- jsonls doesn't really support json5
			-- remove some annoying errors
			if string.match(result.uri, "%.json5$", -6) and result.diagnostics ~= nil then
				local idx = 1
				while idx <= #result.diagnostics do
					-- "Comments are not permitted in JSON."
					if result.diagnostics[idx].code == 521 then
						table.remove(result.diagnostics, idx)
					else
						idx = idx + 1
					end
				end
			end
			on_publish_diagnostics(err, result, ctx, config)
		end,
	},
	on_attach = on_attach,
})

-- requires npm:typescript
require("lspconfig").tsserver.setup({
	capabilities = capabilities,
	handlers = {
		["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
			if result.diagnostics ~= nil then
				local idx = 1
				while idx <= #result.diagnostics do
					if ignored_ts_diagnostic_codes[result.diagnostics[idx].code] then
						table.remove(result.diagnostics, idx)
					else
						idx = idx + 1
					end
				end
			end
			on_publish_diagnostics(err, result, ctx, config)
		end,
	},
	on_attach = function(client, bufnr)
		-- Let null-ls handle formatting
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		client.server_capabilities.documentOnTypeFormattingProvider = false
		on_attach(client, bufnr)
	end,
})

-- requires npm:vscode-langservers-extracted
require("lspconfig").cssls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires brew:rust-analyzer
require("lspconfig").rust_analyzer.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require("lspconfig").lua_ls.setup({
	-- cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
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
