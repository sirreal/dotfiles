local efm_fs_util = require("efmls-configs.fs")
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

local on_attach_module = require("plugins.lsp-attach")
local on_attach = on_attach_module.on_attach
local on_attach_formatting = on_attach_module.on_attach_formatting
local on_attach_without_formatting = on_attach_module.on_attach_without_formatting

vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	virtual_lines = { current_line = true },
	underline = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "󰋼",
			[vim.diagnostic.severity.INFO] = "󰋼",
		},
		-- linehl = {
		-- 	[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
		-- 	[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
		-- 	[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
		-- 	[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
		-- },
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
			[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
			[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
		},
	},
	-- virtual_text = true,
})

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
		["textDocument/publishDiagnostics"] = function(err, result, ctx)
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
			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end,
	},
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires npm:typescript
vim.lsp.config("ts_ls", {
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
			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end,
	},
	on_attach = on_attach_without_formatting,
	capabilities = capabilities,
})
vim.lsp.enable("ts_ls")

-- requires npm:vscode-langservers-extracted
vim.lsp.config("html", {
	capabilities = capabilities,
	on_attach = on_attach,
})
vim.lsp.enable("html")

-- requires npm:vscode-langservers-extracted
vim.lsp.config("cssls", {
	capabilities = capabilities,
	on_attach = on_attach_without_formatting,
})

-- requires npm:cssmodules-language-server
vim.lsp.config("cssmodules_ls", {
	capabilities = capabilities,
	on_attach = on_attach,
})

-- requires npm:yaml-language-server
vim.lsp.config("yamlls", {
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
vim.lsp.enable("yamlls")

-- requires brew:rust-analyzer
local rust_analyzer_handlers = {}
for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
	rust_analyzer_handlers[method] = function(err, result, context)
		if err ~= nil and err.code == -32802 then
			return
		end
		return vim.lsp.handlers[method](err, result, context)
	end
end

vim.lsp.config("rust_analyzer", {
	debug = false,
	capabilities = capabilities,
	on_attach = on_attach,
	handlers = rust_analyzer_handlers,
	settings = {
		["rust-analyzer"] = {
			check = {
				command = { "clippy", "--keep-going" },
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("biome", {
	debug = false,
	capabilities = capabilities,
	on_attach = on_attach_formatting,
	-- root_dir = util.root_pattern("biome.json"),
})
vim.lsp.enable("biome")

vim.lsp.config("oxc", {
	capabilities = capabilities,
	on_attach = on_attach,
	-- root_dir = util.root_pattern("biome.json"),
})

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

-- requires npm:devsense-php-ls
vim.lsp.config("phptools", {
	debug = false,
	on_attach = on_attach_without_formatting,
	php = {
		version = "7.2",
		["workspace.shortOpenTag"] = false,
		["inlayHints.parameters.enabled"] = true,
		stubs = {
			"bcmath",
			"bz2",
			"Core",
			"ctype",
			"curl",
			"date",
			"dba",
			"dom",
			"exif",
			"FFI",
			"fileinfo",
			"filter",
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

			"wordpress",
			-- "xdebug",
		},
	},
	init_options = {
		["0"] = require("plugins.phptools-key"),
	},
})
vim.lsp.enable("phptools")

-- requires npm:intelephense
vim.lsp.config("intelephense", {
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
					"**/wp-content/languages/**",

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
				-- "xdebug",
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
-- vim.lsp.enable("intelephense")

-- requires brew:lua-language-server
vim.lsp.config("lua_ls", {
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
vim.lsp.enable("lua_ls")

vim.lsp.config("phpactor", {
	on_attach = on_attach_without_formatting,
	init_options = {
		["language_server_phpstan.enabled"] = true,
		["language_server_psalm.enabled"] = false,
	},
})

local efm_languages = {
	lua = {
		require("efmls-configs.formatters.stylua"),
	},
	php = {
		require("efmls-configs.linters.phpcs"),
	},
}

local phpcbf_executable = efm_fs_util.executable("phpcbf", efm_fs_util.Scope.COMPOSER)
if phpcbf_executable ~= "phpcbf" then
	vim.list_extend(efm_languages.php, {
		{
			formatCommand = string.format("%s -q --stdin-path='${INPUT}' -", phpcbf_executable),
			formatStdin = true,
			formatIgnoreExitCode = true,
		},
	})
end

local phpstan_executable = efm_fs_util.executable("phpstan", efm_fs_util.Scope.COMPOSER)
if phpstan_executable ~= "phpstan" then
	vim.list_extend(efm_languages.php, {
		require("efmls-configs.linters.phpstan"),
	})
end

local has_prettier = string.sub(
	efm_fs_util.executable("prettier", efm_fs_util.Scope.NODE),
	-string.len("/node_modules/.bin/prettier")
) == "/node_modules/.bin/prettier"
if has_prettier then
	efm_languages = vim.tbl_extend("force", efm_languages, {
		javascript = { require("efmls-configs.formatters.prettier") },
		typescript = { require("efmls-configs.formatters.prettier") },
		typescriptreact = { require("efms-configs.formatters.prettier") },

		css = { require("efmls-configs.formatters.prettier") },
		sass = { require("efmls-configs.formatters.prettier") },
		scss = { require("efmls-configs.formatters.prettier") },

		json = { require("efmls-configs.formatters.prettier") },
		json5 = { require("efmls-configs.formatters.prettier") },
		jsonc = { require("efmls-configs.formatters.prettier") },

		markdown = { require("efmls-configs.formatters.prettier") },

		yaml = { require("efmls-configs.formatters.prettier") },
	})
end

-- requires brew:efm-langserver
vim.lsp.config("efm", {
	cmd = { "/Users/jonsurrell/jon/efm-langserver/efm-langserver" },
	filetypes = vim.tbl_keys(efm_languages),
	settings = {
		languages = efm_languages,
	},
	init_options = {
		codeAction = true,
		completion = true,
		documentFormatting = true,
		documentRangeFormatting = true,
		documentSymbol = true,
		hover = true,
	},
	capabilities = capabilities,
	on_attach = on_attach_formatting,
})
vim.lsp.enable("efm")

-- requires brew:gopls
vim.lsp.config("gopls", {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		gopls = {
			hints = {},
		},
	},
})
vim.lsp.enable("gopls")

-- requires cargo:harper-ls
-- lspconfig.harper_ls.setup({
-- 	settings = {
-- 		["harper-ls"] = {
-- 			userDictPath = "~/.config/harper-user-dict.txt",
-- 			fileDictPath = "~/.config/harper/",
-- 		},
-- 	},
-- })

-- requires brew:zls
vim.lsp.enable("zls")
