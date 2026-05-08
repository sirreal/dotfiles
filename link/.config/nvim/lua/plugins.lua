local function isDarkMode()
	return os.execute("defaults read -globalDomain AppleInterfaceStyle 1> /dev/null 2> /dev/null")
		== 0
end

if isDarkMode() then
	vim.o.background = "dark"
else
	vim.o.background = "light"
end

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if
			ev.data.spec.name == "nvim-treesitter"
			and (ev.data.kind == "install" or ev.data.kind == "update")
		then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },

	{ src = "https://github.com/subnut/nvim-ghost.nvim" },

	{ src = "https://github.com/creativenull/efmls-configs-nvim" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },

	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },

	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/folke/trouble.nvim", version = "main" },

	{ src = "https://github.com/onsails/lspkind-nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/vuki656/package-info.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/hrsh7th/nvim-cmp" },

	{ src = "https://github.com/lewis6991/gitsigns.nvim", version = "main" },

	{ src = "https://github.com/nvim-lualine/lualine.nvim" },

	{ src = "https://github.com/godlygeek/tabular" },
	{ src = "https://github.com/junegunn/vim-easy-align" },
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/tpope/vim-repeat" },
	{ src = "https://github.com/tpope/vim-rsi" },
	{ src = "https://github.com/tpope/vim-surround" },
	{ src = "https://github.com/tpope/vim-eunuch" },
})

vim.pack.add({
	{ src = "https://github.com/github/copilot.vim", version = "release" },
}, { load = false })

vim.opt.rtp:prepend("/Users/jonsurrell/jon/wp-commit-msg")

require("kanagawa").setup({
	compile = false,
	undercurl = true,
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = { bold = true },
	typeStyle = {},
	transparent = false,
	dimInactive = false,
	terminalColors = true,
	colors = {
		palette = {},
		theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
	},
	overrides = function(colors)
		return {}
	end,
	theme = "wave",
	background = {
		dark = "wave",
		light = "lotus",
	},
})
vim.cmd("colorscheme kanagawa-lotus")

require("nvim-web-devicons").setup({ default = true })

require("plugins.treesitter")
require("plugins.treesitter-textobjects")
require("treesitter-context")

require("plugins.lsp")

require("trouble").setup({})

require("plugins.cmp")
require("plugins.telescope")

require("gitsigns").setup()

require("lualine").setup({
	options = {
		theme = "modus-vivendi",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			"diff",
			"diagnostics",
		},
		lualine_c = { "filename" },
		lualine_x = {
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})

vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<Leader><Tab>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "php", "typescript", "typescriptreact", "markdown" },
	once = true,
	callback = function()
		vim.cmd.packadd("copilot.vim")
	end,
})
