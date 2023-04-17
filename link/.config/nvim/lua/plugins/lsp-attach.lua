local lsp_format_augroup = vim.api.nvim_create_augroup("LspFormat", {})

return function(client, bufnr)
	require("lsp_signature").on_attach()

	local map = function(type, key, value)
		vim.api.nvim_buf_set_keymap(bufnr, type, key, value, { noremap = true, silent = true })
	end

	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	--
	-- core lsp
	--
	vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
	vim.cmd("command! LspCodeActionRange lua vim.lsp.buf.range_code_action()")
	vim.cmd("command! LspDeclaration lua vim.lsp.buf.declaration()")
	vim.cmd("command! LspDefinition lua vim.lsp.buf.definition()")
	-- vim.cmd("command! LspDianosticLine lua vim.lsp.diagnostic.show_line_diagnostics()")
	-- vim.cmd("command! LspDianosticNext lua vim.lsp.diagnostic.goto_next()")
	-- vim.cmd("command! LspDianosticPrev lua vim.lsp.diagnostic.goto_prev()")
	vim.cmd("command! LspFormat lua vim.lsp.buf.format()")
	-- vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
	vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
	-- vim.cmd("command! LspReferences lua vim.lsp.buf.references()")
	-- vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
	-- vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
	vim.cmd("command! LspTypeDefinition lua vim.lsp.buf.type_definition()")

	--
	-- lspsaga variants
	--
	-- vim.cmd("command! LspCodeAction lua require('lspsaga.codeaction').code_action()")
	-- vim.cmd("command! LspCodeActionRange lua require('lspsaga.codeaction').range_code_action()")
	vim.cmd("command! LspDianosticLine lua require('lspsaga.diagnostic').show_line_diagnostics()")
	vim.cmd("command! LspDianosticNext lua require('lspsaga.diagnostic').navigate('next')()")
	vim.cmd("command! LspDianosticPrev lua require('lspsaga.diagnostic').navigate('prev')()")
	vim.cmd("command! LspHover lua require('lspsaga.hover').render_hover_doc()")
	vim.cmd("command! LspReferences lua require('lspsaga.provider').lsp_finder()")
	vim.cmd("command! LspRename lua require('lspsaga.rename').rename()")
	vim.cmd("command! LspSignatureHelp lua require('lspsaga.signaturehelp').signature_help()")

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

	if client.server_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
				augroup LspAutohighlight
				autocmd! * <buffer>
				autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
				augroup END
			]],
			true
		)
	end

	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = lsp_format_augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = lsp_format_augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end

	-- vim.notify("LSP " .. client.name .. " started.", vim.log.levels.INFO)
end
