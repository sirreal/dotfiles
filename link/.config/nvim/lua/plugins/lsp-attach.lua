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
	-- vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
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
	vim.cmd("command! LspCodeAction Lspsaga code_action")
	vim.cmd("command! LspDianosticLine Lspsaga show_line_diagnostics")
	vim.cmd("command! LspDianosticNext Lspsaga diagnostic_jump_next")
	vim.cmd("command! LspDianosticPrev Lspsaga diagnostic_jump_prev")
	vim.cmd("command! LspHover Lspsaga hover_doc")
	vim.cmd("command! LspReferences Lspsaga lsp_finder")
	vim.cmd("command! LspRename Lspsaga rename project")

	map("n", "gd", "<cmd>LspDefinition<CR>")
	map("n", "gi", "<cmd>LspImplementation<CR>")
	map("n", "gr", "<cmd>LspRename<CR>")
	map("n", "gR", "<cmd>LspReferences<CR>")
	map("n", "ga", "<cmd>LspCodeAction<CR>")
	map("n", "K", "<cmd>LspHover<CR>")

	map("n", "[d", "<cmd>LspDianosticPrev<CR>")
	map("n", "]d", "<cmd>LspDianosticNext<CR>")
	map("n", "<Leader>a", "<cmd>LspDianosticLine<CR>")
	map("i", "<C-x><C-x>", "<cmd>LspSignatureHelp<CR>")

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
