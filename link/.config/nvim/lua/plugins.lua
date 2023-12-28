if "Dark" == io.popen("defaults read -g AppleInterfaceStyle 2> /dev/null", "r"):read() then
	vim.o.background = "dark"
else
	vim.o.background = "light"
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				background = {
					light = "latte",
					dark = "frappe",
				},
				integrations = {
					cmp = true,
					gitsigns = true,
					lsp_trouble = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "undercurl" },
							hints = { "underdotted" },
							warnings = { "undercurl" },
							information = { "underdotted" },
						},
						inlay_hints = {
							background = true,
						},
					},
					telescope = { enabled = true },
					treesitter = true,
				},
			})
			vim.cmd([[colorscheme catppuccin]])
			-- end
		end,
	},

	-- Highlights
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("plugins.treesitter")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-refactor",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("plugins.treesitter-textobjects")
		end,
	},

	--
	-- Copilot
	--
	-- { "github/copilot.vim", git_branch = "release" },

	--
	-- LSP
	--

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"ray-x/lsp_signature.nvim",
		},
		config = function()
			require("plugins.lsp")
		end,
	},

	{
		"nvimdev/lspsaga.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("lspsaga").setup({
				lightbulb = { enable = false },
				ui = {
					kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
				},
			})
		end,
	},

	-- Linting, autoformatting…
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("plugins.null-ls")
		end,
	},

	{
		"simrat39/rust-tools.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("rust-tools").setup({
				server = {
					on_attach = require("plugins.lsp-attach"),
				},
			})
		end,
	},

	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	},

	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		config = function()
			require("trouble").setup({})
		end,
		dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
	},

	{
		"saecki/crates.nvim",
		version = "v0.4.0",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("crates").setup({
				-- src = {
				-- 	cmp = {
				-- 		enabled = true,
				-- 	},
				-- },
				null_ls = {
					enabled = true,
					name = "crates.nvim",
				},
			})
		end,
	},

	{
		"vuki656/package-info.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		config = function()
			require("package-info").setup({})
		end,
	},

	--
	-- Completion
	--
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"neovim/nvim-lspconfig",
			"onsails/lspkind-nvim",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			require("plugins.cmp")
		end,
	},

	--
	-- Finding stuff
	--
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"vuki656/package-info.nvim",
		},
		config = function()
			require("plugins.telescope")
		end,
		cmd = "Telescope",
	},

	--
	-- Git
	--

	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup()
		end,
	},

	-- {
	--   "TimUntersberger/neogit",
	--   cmd = "Neogit",
	--   disable = true,
	-- },

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
				},
				sections = {
					lualine_c = {
						{ "filename", path = 1 },
					},
				},
			})
		end,
	},

	"godlygeek/tabular",
	"junegunn/vim-easy-align",

	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		dependencies = {
			"tpope/vim-commentary",
			"nvim-treesitter/nvim-treesitter",
		},
	},

	{ "tpope/vim-fugitive", cmd = { "Git" } },
	"tpope/vim-repeat",
	"tpope/vim-rsi",
	"tpope/vim-surround",
	"tpope/vim-eunuch",
})
