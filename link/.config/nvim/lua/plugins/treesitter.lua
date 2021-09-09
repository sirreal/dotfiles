require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"graphql",
		"html",
		"javascript",
		"jsdoc",
		"json",
		"jsonc",
		"lua",
		"php",
		"python",
		"rust",
		"tsx",
		"typescript",
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
