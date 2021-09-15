local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd("packadd packer.nvim")
end

require("packer.luarocks").setup_paths()
return require("packer").startup(function()
	use("wbthomason/packer.nvim")
	use_rocks({ "lualogging" })

	use({
		"navarasu/onedark.nvim",
		config = function()
			require("onedark").setup()
		end,
	})

	-- Highlights
	use({
		"nvim-treesitter/nvim-treesitter",
		requires = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		run = ":TSUpdate",
		config = [[require("plugins.treesitter")]],
	})

	-- LSP
	--
	-- 'onsails/lspkind-nvim',
	-- '~/projects/personal/lsp-status.nvim',
	-- 'ray-x/lsp_signature.nvim',
	-- 'kosayoda/nvim-lightbulb',
	use({

		"neovim/nvim-lspconfig",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = [[require("plugins.lsp")]],
	})
	use({
		"nvim-lua/lsp_extensions.nvim",
		requires = { "neovim/nvim-lspconfig" },
	})

	use({
		"glepnir/lspsaga.nvim",
		requires = { "neovim/nvim-lspconfig" },
		config = function()
			require("lspsaga").init_lsp_saga()
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
					on_attach = require("plugins.utils").on_attach,
				},
			})
		end,
	})

	use({
		"kyazdani42/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	})

	use({
		"folke/trouble.nvim",
		config = function()
			require("trouble").setup({})
		end,
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	--
	-- Completion
	--
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = [[require("plugins.cmp")]],
	})

	--
	-- Finding stuff
	--
	use({
		{
			"nvim-telescope/telescope.nvim",
			requires = {
				"nvim-lua/popup.nvim",
				"nvim-lua/plenary.nvim",
				"telescope-frecency.nvim",
				"telescope-fzf-native.nvim",
			},
			config = [[require("plugins.telescope")]],
			cmd = "Telescope",
			module = "telescope",
		},
		{
			"nvim-telescope/telescope-frecency.nvim",
			after = "telescope.nvim",
			requires = "tami5/sql.nvim",
		},
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			run = "make",
		},
	})

	-- Git
	use({
		{ "tpope/vim-fugitive", cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" }, disable = true },
		{
			"lewis6991/gitsigns.nvim",
			requires = { "nvim-lua/plenary.nvim" },
			config = function()
				require("gitsigns").setup()
			end,
		},
		{
			"TimUntersberger/neogit",
			cmd = "Neogit",
		},
	})

	use({
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				easing_function = "cubic",
			})
		end,
	})

	use("editorconfig/editorconfig-vim")

	-- use("vim-airline/vim-airline")
	-- use("vim-airline/vim-airline-themes")

	use({
		"glepnir/galaxyline.nvim",
		branch = "main",
		-- your statusline
		config = function()
			require("plugins.statusline")
		end,
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	use("godlygeek/tabular")

	use("junegunn/vim-easy-align")

	use({
		"folke/twilight.nvim",
		config = function()
			require("twilight").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})

	use({
		"JoosepAlviste/nvim-ts-context-commentstring",
		requires = {
			"tpope/vim-commentary",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				context_commentstring = {
					enable = true,
				},
			})
		end,
	})

	use("tpope/vim-repeat")
	use("tpope/vim-rsi")
	use("tpope/vim-surround")
	-- use 'tpope/vim-tbone'

	-- use("rust-lang/rust.vim")
end)
