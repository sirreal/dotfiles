local lspconfig = require("lspconfig")
local on_attach = require("plugins.lsp-attach")
local util = require("lspconfig.util")

local on_attach_without_formatting = function(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
	client.server_capabilities.documentOnTypeFormattingProvider = false
	on_attach(client, bufnr)
end

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
lspconfig.eslint.setup({
	settings = {
		format = false,
		packageManager = "yarn",
	},
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires npm:stylelint-lsp
lspconfig.stylelint_lsp.setup({
	settings = {
		reportDescriptionlessDisables = true,
		reportInvalidScopeDisables = true,
		reportNeedlessDisables = true,
		stylelintplus = {},
	},
	filetypes = { "css", "scss" },
	capabilities = capabilities,
	on_attach = on_attach_without_formatting,
})

-- requires npm:vscode-langservers-extracted
lspconfig.jsonls.setup({
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
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires npm:typescript
lspconfig.ts_ls.setup({
	-- init_options = {
	-- 	preferences = {
	-- 		-- https://github.com/microsoft/TypeScript/blob/79a851426c514a12a75b342e8dd2460ee6615f73/tests/cases/fourslash/fourslash.ts#L683
	--
	-- 		includeInlayParameterNameHints = "all",
	-- 		includeInlayParameterNameHintsWhenArgumentMatchesName = true,
	-- 		includeInlayFunctionParameterTypeHints = true,
	-- 		includeInlayVariableTypeHints = true,
	-- 		includeInlayVariableTypeHintsWhenTypeMatchesName = true,
	-- 		includeInlayPropertyDeclarationTypeHints = true,
	-- 		includeInlayFunctionLikeReturnTypeHints = true,
	-- 		includeInlayEnumMemberValueHints = true,
	-- 		interactiveInlayHints = true,
	-- 	},
	-- },
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
	on_attach = on_attach_without_formatting,
	capabilities = capabilities,
})

-- requires npm:vscode-langservers-extracted
lspconfig.cssls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires npm:cssmodules-language-server
lspconfig.cssmodules_ls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires npm:yaml-language-server
lspconfig.yamlls.setup({
	settings = {
		yaml = {
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
			},
		},
	},
	capabilities = capabilities,
	on_attach = on_attach,
})

-- DO NOT USE - conflicts with rust-tools
-- requires brew:rust-analyzer
-- lspconfig.rust_analyzer.setup({
-- 	capabilities = capabilities,
-- 	on_attach = on_attach,
-- })

-- lspconfig.biome.setup({
-- 	capabilities = capabilities,
-- 	on_attach = on_attach,
-- 	root_dir = util.root_pattern("biome.json"),
-- })

-- lspconfig.oxc.setup({
-- 	capabilities = capabilities,
-- 	on_attach = on_attach,
-- 	-- root_dir = util.root_pattern("biome.json"),
-- })

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

-- requires npm:intelephense
lspconfig.intelephense.setup({
	on_attach = on_attach_without_formatting,
	capabilities = capabilities,
	settings = {
		-- See https://github.com/bmewburn/intelephense-docs/blob/master/installation.md
		intelephense = {
			environment = { phpVersion = "7.2" },
			files = {
				maxSize = 350000,
				exclude = {
					--
					-- Defaults
					--
					"**/.git/**",
					"**/.svn/**",
					"**/.DS_Store/**",
					"**/node_modules/**",
					"**/vendor/**/{Tests,tests}/**",
					"**/.history/**",
					"**/vendor/**/vendor/**",

					--
					-- Disabled defaults
					--
					"**/.hg/**",
					"**/CVS/**",
					"**/bower_components/**",

					--
					-- Additions
					--
					"**/build/**",
				},
			},
			stubs = {
				-- defaults
				"apache",
				"bcmath",
				"bz2",
				"Core",
				"ctype",
				"curl",
				"date",
				"dba",
				"dom",
				"enchant",
				"exif",
				"FFI",
				"fileinfo",
				"filter",
				"fpm",
				"ftp",
				"gd",
				"gettext",
				"gmp",
				"hash",
				"iconv",
				"intl",
				"json",
				"ldap",
				"libxml",
				"mbstring",
				"meta",
				"mysqli",
				"oci8",
				"odbc",
				"openssl",
				"pcntl",
				"pcre",
				"Phar",
				"posix",
				"pspell",
				"readline",
				"Reflection",
				"session",
				"shmop",
				"SimpleXML",
				"sockets",
				"sodium",
				"SPL",
				"sqlite3",
				"standard",
				"superglobals",
				"sysvmsg",
				"sysvsem",
				"sysvshm",
				"tidy",
				"tokenizer",
				"xml",
				"xmlreader",
				"xmlrpc",
				"xmlwriter",
				"xsl",
				"Zend OPcache",
				"zip",
				"zlib",

				--
				-- Disabled defaults
				--

				-- "PDO",
				-- "calendar",
				-- "com_dotnet",
				-- "imap",
				-- "pdo_ibm",
				-- "pdo_mysql",
				-- "pdo_pgsql",
				-- "pdo_sqlite",
				-- "pgsql",
				-- "snmp",
				-- "soap",

				--
				-- Additions
				--

				-- "wordpress",
			},
			format = {
				enable = false,
			},
			diagnostics = {
				embeddedLanguages = false,
			},
		},
	},
})

-- requires brew:lua-language-server
lspconfig.lua_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			format = {
				enable = false,
			},
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
