if "Dark" == io.popen("defaults read -g AppleInterfaceStyle 2> /dev/null", "r"):read() then
	vim.o.background = "dark"
else
	vim.o.background = "light"
end

local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd("packadd packer.nvim")
end

return require("packer").startup(function(use)
	use({ "wbthomason/packer.nvim" })

	use({
		"folke/tokyonight.nvim",
		config = function()
			if
				"Dark" == io.popen("defaults read -g AppleInterfaceStyle 2> /dev/null", "r"):read()
			then
				require("tokyonight").setup({ style = "storm" })
				vim.cmd([[colorscheme tokyonight-storm]])
			end
		end,
	})
	use({
		"neanias/everforest-nvim",
		config = function()
			if
				"Dark" ~= io.popen("defaults read -g AppleInterfaceStyle 2> /dev/null", "r"):read()
			then
				require("everforest").setup()
				vim.cmd([[colorscheme everforest]])
			end
		end,
	})

	-- Highlights
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = [[require("plugins.treesitter")]],
	})

	use({
		"nvim-treesitter/nvim-treesitter-refactor",
		after = "nvim-treesitter",
		requires = "nvim-treesitter/nvim-treesitter",
	})

	use({
		"nvim-treesitter/nvim-treesitter-textobjects",
		after = "nvim-treesitter",
		requires = "nvim-treesitter/nvim-treesitter",
		config = [[require("plugins.treesitter-textobjects")]],
	})

	--
	-- Copilot
	--
	-- use({ "github/copilot.vim", git_branch = "release" })

	--
	-- LSP
	--

	use({
		"neovim/nvim-lspconfig",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"ray-x/lsp_signature.nvim",
		},
		config = [[require("plugins.lsp")]],
	})
	use({
		"nvim-lua/lsp_extensions.nvim",
		requires = { "neovim/nvim-lspconfig" },
	})

	use({
		"simrat39/symbols-outline.nvim",
		cmd = { "SymbolsOutline" },
		requires = { "neovim/nvim-lspconfig" },
	})

	use({
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		requires = { "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("lspsaga").setup({})
		end,
	})

	-- Linting, autoformatting…
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
		},
		config = [[require("plugins.null-ls")]],
	})

	use({
		"simrat39/rust-tools.nvim",
		requires = {
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
			"nvim-lua/popup.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("rust-tools").setup({
				server = {
					on_attach = require("plugins.lsp-attach"),
				},
			})
		end,
	})

	use({
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	})

	use({
		"folke/trouble.nvim",
		cmd = "Trouble",
		config = function()
			require("trouble").setup({})
		end,
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
	})

	--
	-- Completion
	--
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"neovim/nvim-lspconfig",
			"onsails/lspkind-nvim",
			"saadparwaiz1/cmp_luasnip",
		},
		config = [[require("plugins.cmp")]],
	})

	--
	-- Finding stuff
	--
	use({
		-- {
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			-- "nvim-telescope/telescope-frecency.nvim",
			-- "nvim-telescope/telescope-fzf-native.nvim",
		},
		config = [[require("plugins.telescope")]],
		cmd = "Telescope",
		module = "telescope",
		-- },
		-- {
		--   "nvim-telescope/telescope-frecency.nvim",
		--   requires = "tami5/sql.nvim",
		-- },
		-- {
		--   "nvim-telescope/telescope-fzf-native.nvim",
		--   run = "make",
		-- },
	})

	--
	-- Git
	--

	-- use({
	--   "lewis6991/gitsigns.nvim",
	--   requires = { "nvim-lua/plenary.nvim" },
	--   config = function()
	--     require("gitsigns").setup()
	--   end,
	-- })

	-- use({
	--   "TimUntersberger/neogit",
	--   cmd = "Neogit",
	--   disable = true,
	-- })

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
				},
				sections = {
					lualine_c = {
						{ "filename", path = 1 },
					},
				},
			})
		end,
	})

	use("godlygeek/tabular")
	use("junegunn/vim-easy-align")

	use({
		"JoosepAlviste/nvim-ts-context-commentstring",
		requires = {
			"tpope/vim-commentary",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				context_commentstring = {
					enable = true,
				},
			})
		end,
	})

	use({ "tpope/vim-fugitive", cmd = { "Git" } })
	use("tpope/vim-repeat")
	use("tpope/vim-rsi")
	use("tpope/vim-surround")
	use("tpope/vim-eunuch")

	-- use("rust-lang/rust.vim")
end)
