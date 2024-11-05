local lsp_format_augroup = vim.api.nvim_create_augroup("LspFormat", {})

local function on_attach_formatting(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = lsp_format_augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = lsp_format_augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
			end,
		})
	end
end

local function on_attach(client, bufnr)
	local lsp_signature_module_available, lsp_signature = pcall(require, "lsp_signature")
	if lsp_signature_module_available then
		lsp_signature.on_attach({
			bind = true,
			handler_opts = {
				hint_enable = false,
			},
		})
	end

	local map = function(type, key, value)
		vim.api.nvim_buf_set_keymap(bufnr, type, key, value, { noremap = true, silent = true })
	end

	vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })

	--
	-- core lsp
	--
	-- vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
	vim.cmd("command! LspCodeActionRange lua vim.lsp.buf.range_code_action()")
	-- vim.cmd("command! LspDefinition lua vim.lsp.buf.definition()")
	-- vim.cmd("command! LspDiagnosticLine lua vim.diagnostic.open_float()")
	-- vim.cmd("command! LspDiagnosticNext lua vim.diagnostic.goto_next()")
	-- vim.cmd("command! LspDiagnosticPrev lua vim.diagnostic.goto_prev()")
	vim.cmd("command! LspFormat lua vim.lsp.buf.format()")
	-- vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
	-- vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
	-- vim.cmd("command! LspReferences lua vim.lsp.buf.references()")
	-- vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
	vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
	vim.cmd("command! LspTypeDefinition lua vim.lsp.buf.type_definition()")

	--
	-- Telescope variants
	--
	vim.cmd("command! LspDefinition Telescope lsp_definitions")
	vim.cmd("command! LspImplementation Telescope lsp_implementations")
	vim.cmd("command! LspReferences Telescope lsp_references")

	vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
	vim.cmd("command! LspDiagnosticLine lua vim.diagnostic.open_float()")
	vim.cmd("command! LspDiagnosticNext lua vim.diagnostic.goto_next()")
	vim.cmd("command! LspDiagnosticPrev lua vim.diagnostic.goto_prev()")
	vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
	vim.cmd("command! LspRename lua vim.lsp.buf.rename()")

	map("n", "gd", "<cmd>LspDefinition<CR>")
	map("n", "gi", "<cmd>LspImplementation<CR>")
	map("n", "gr", "<cmd>LspRename<CR>")
	map("n", "gR", "<cmd>LspReferences<CR>")
	map("n", "ga", "<cmd>LspCodeAction<CR>")
	map("n", "K", "<cmd>LspHover<CR>")

	map("n", "[d", "<cmd>LspDiagnosticPrev<CR>")
	map("n", "]d", "<cmd>LspDiagnosticNext<CR>")
	map("n", "<Leader>a", "<cmd>LspDiagnosticLine<CR>")
	map("i", "<C-x><C-x>", "<cmd>LspSignatureHelp<CR>")

	-- if client.server_capabilities.document_highlight then
	-- 	vim.api.nvim_exec(
	-- 		[[
	-- 			augroup LspAutohighlight
	-- 			autocmd! * <buffer>
	-- 			autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
	-- 			autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
	-- 			autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
	-- 			augroup END
	-- 		]],
	-- 		true
	-- 	)
	-- end

	on_attach_formatting(client, bufnr)

	-- vim.notify("LSP " .. client.name .. " started.", vim.log.levels.INFO)

	if client.supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr })
	end
end

return {
	on_attach = on_attach,
	on_attach_formatting = on_attach_formatting,
}
