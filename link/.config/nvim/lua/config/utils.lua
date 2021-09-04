local M = {}

M.on_attach = function(client, bufnr)
	print("LSP " .. client.name .. " started.")
	local map = function(type, key, value)
		vim.api.nvim_buf_set_keymap(bufnr, type, key, value, { noremap = true, silent = true })
	end

	vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
	vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting_sync()")
	-- vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
	-- vim.cmd("command! LspCodeActionRange lua vim.lsp.buf.range_code_action()")
	-- vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
	-- vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
	vim.cmd("command! LspOrganize lua lsp_organize_imports()")
	vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
	vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
	vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
	-- vim.cmd("command! LspDiagPrev lua vim.lsp.diagnostic.goto_prev()")
	-- vim.cmd("command! LspDiagNext lua vim.lsp.diagnostic.goto_next()")
	-- vim.cmd("command! LspDiagLine lua vim.lsp.diagnostic.show_line_diagnostics()")
	-- vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")

	vim.cmd("command! LspCodeAction lua require('lspsaga.codeaction').code_action()")
	vim.cmd("command! LspCodeActionRange lua require('lspsaga.codeaction').range_code_action()")
	vim.cmd("command! LspHover lua require('lspsaga.hover').render_hover_doc()")
	vim.cmd("command! LspRename lua require('lspsaga.rename').rename()")
	vim.cmd("command! LspDiagPrev lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()")
	vim.cmd("command! LspDiagNext lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()")
	vim.cmd("command! LspDiagLine lua require('lspsaga.diagnostic').show_line_diagnostics()")
	vim.cmd("command! LspSignatureHelp lua require('lspsaga.signaturehelp').signature_help()")

	map("n", "gd", ":LspDef<CR>")
	map("n", "gD", ":LspDef<CR>")
	map("n", "gr", ":LspRename<CR>")
	map("n", "gR", ":LspRefs<CR>")
	map("n", "gy", ":LspTypeDef<CR>")
	map("n", "K", ":LspHover<CR>")
	map("n", "gs", ":LspOrganize<CR>")
	map("n", "[a", ":LspDiagPrev<CR>")
	map("n", "]a", ":LspDiagNext<CR>")
	map("n", "ga", ":LspCodeAction<CR>")
	map("n", "<Leader>a", ":LspDiagLine<CR>")
	map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>")

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
end

return M
