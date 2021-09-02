local null_ls = require("null-ls")
local root_pattern = require("lspconfig/util").root_pattern

function root_dir(bufnr)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	return root_pattern("package.json")(fname) or root_pattern(".git")(fname)
end

function require_node_bin(bufnr) end

local eslint = null_ls.builtins.diagnostics.eslint
null_ls.config({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.diagnostics.eslint.with({
			command = "yarn",
			args = { "eslint", "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
		}),
	},
})
require("lspconfig")["null-ls"].setup({
	on_attach = function(client, bufnr)
		print(root_dir(bufnr))
		require("config.utils").on_attach(client, bufnr)
	end,
})
