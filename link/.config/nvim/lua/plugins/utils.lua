local M = {}

M.log = {}
M.log.debug = function() end
M.log.info = function() end
M.log.warn = function() end
M.log.error = function() end
M.log.fatal = function() end

if vim.g.DEBUG then
	local logfile = vim.fn.stdpath("cache") .. "/config.log"
	local Logging = require("logging")
	require("logging.rolling_file")
	local logger = Logging.rolling_file({ filename = logfile, maxFileSize = 1024 })

	logger:setLevel(vim.g.DEBUG)
	M.log.debug = function(...)
		logger:debug(...)
	end
	M.log.info = function(...)
		logger:info(...)
	end
	M.log.warn = function(...)
		logger:warn(...)
	end
	M.log.error = function(...)
		logger:error(...)
	end
	M.log.fatal = function(...)
		logger:fatal(...)
	end
end

if false then
	M.log.debug("d")
	M.log.info("i")
	M.log.warn("w")
	M.log.error("e")
	M.log.fatal("f")
end

M.on_attach = function(client, bufnr)
	local map = function(type, key, value)
		vim.api.nvim_buf_set_keymap(bufnr, type, key, value, { noremap = true, silent = true })
	end

	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	vim.cmd("command! LspDefinition lua vim.lsp.buf.definition()")
	vim.cmd("command! LspDeclaration lua vim.lsp.buf.declaration()")
	vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting_sync()")
	vim.cmd("command! LspTypeDefinition lua vim.lsp.buf.type_definition()")
	vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
	-- vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
	-- vim.cmd("command! LspCodeActionRange lua vim.lsp.buf.range_code_action()")
	-- vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
	-- vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
	-- vim.cmd("command! LspReferences lua vim.lsp.buf.references()")
	-- vim.cmd("command! LspDianosticPrev lua vim.lsp.diagnostic.goto_prev()")
	-- vim.cmd("command! LspDianosticNext lua vim.lsp.diagnostic.goto_next()")
	-- vim.cmd("command! LspDianosticLine lua vim.lsp.diagnostic.show_line_diagnostics()")
	-- vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")

	vim.cmd("command! LspCodeAction lua require('lspsaga.codeaction').code_action()")
	vim.cmd("command! LspCodeActionRange lua require('lspsaga.codeaction').range_code_action()")
	vim.cmd("command! LspHover lua require('lspsaga.hover').render_hover_doc()")
	vim.cmd("command! LspRename lua require('lspsaga.rename').rename()")
	vim.cmd("command! LspDianosticPrev lua require('lspsaga.diagnostic').lsp_jump_diagnostic_prev()")
	vim.cmd("command! LspDianosticNext lua require('lspsaga.diagnostic').lsp_jump_diagnostic_next()")
	vim.cmd("command! LspDianosticLine lua require('lspsaga.diagnostic').show_line_diagnostics()")
	vim.cmd("command! LspSignatureHelp lua require('lspsaga.signaturehelp').signature_help()")
	vim.cmd("command! LspReferences lua require('lspsaga.provider').lsp_finder()")

	map("n", "gd", ":LspDefinition<CR>")
	map("n", "gi", ":LspImplementation<CR>")
	map("n", "gr", ":LspRename<CR>")
	map("n", "gR", ":LspReferences<CR>")
	map("n", "ga", ":LspCodeAction<CR>")
	map("n", "K", ":LspHover<CR>")

	map("n", "[d", ":LspDianosticPrev<CR>")
	map("n", "]d", ":LspDianosticNext<CR>")
	map("n", "<Leader>a", ":LspDianosticLine<CR>")
	map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>")

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

	if client.resolved_capabilities.document_formatting then
		vim.api.nvim_exec(
			[[
				augroup LspAutocommands
				autocmd! * <buffer>
				autocmd BufWrite <buffer> LspFormatting
				augroup END
			]],
			true
		)
	end
	M.log.info("LSP " .. client.name .. " started.")
end

return M
