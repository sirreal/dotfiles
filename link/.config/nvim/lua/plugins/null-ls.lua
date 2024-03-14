local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.diagnostics.phpcs.with({
			command = "composer",
			extra_args = { "exec", "--", "phpcs" },
			prepend_extra_args = true,
		}),
		null_ls.builtins.diagnostics.stylelint,

		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylua,

		-- Not using dprint now
		-- null_ls.builtins.formatting.dprint.with({
		-- 	extra_filetypes = {
		-- 		"css",
		-- 		"dockerfile",
		-- 		"json5",
		-- 		"jsonc",
		-- 		"sass",
		-- 		"scss",
		-- 	},
		-- }),

		--
		-- This _almost_ works, but phpcbf exits with 1 which causes composer to error and not print the formatting to stdout 😖
		--
		-- null_ls.builtins.formatting.phpcbf.with({
		-- 	command = "composer",
		-- 	extra_args = { "exec", "--", "phpcbf" },
		-- 	prepend_extra_args = true,
		-- 	check_exit_code = function(code, stderr)
		-- 		local success = code <= 1
		-- 		print("exit code", code, success, stderr)
		-- 		return false

		-- 		-- if not success then
		-- 		-- 	print(stderr)
		-- 		-- end

		-- 		-- return success
		-- 	end,
		-- }),
	},
	on_attach = require("plugins.lsp-attach"),
})
