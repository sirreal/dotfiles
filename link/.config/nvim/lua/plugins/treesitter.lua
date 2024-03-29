require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"diff",
		"git_rebase",
		"gitcommit",
		"graphql",
		"html",
		"ini",
		"javascript",
		"jsdoc",
		"json",
		"json5",
		"jsonc",
		"lua",
		"markdown",
		"markdown_inline",
		"php",
		"python",
		"rust",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"yaml",
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
