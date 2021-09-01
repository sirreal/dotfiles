local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd("packadd packer.nvim")
end

return require("packer").startup(function()
	use("wbthomason/packer.nvim")

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
		config = [[require('config.treesitter')]],
	})

	-- LSP
	--
	-- 'onsails/lspkind-nvim',
	-- '~/projects/personal/lsp-status.nvim',
	-- 'folke/trouble.nvim',
	-- 'ray-x/lsp_signature.nvim',
	-- 'kosayoda/nvim-lightbulb',
	use({

		"neovim/nvim-lspconfig",
		config = [[require('config.lsp')]],
	})
	use({
		"nvim-lua/lsp_extensions.nvim",
		requires = { "neovim/nvim-lspconfig" },
	})

	-- Linting, autoformatting…
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local null_ls = require("null-ls")

			null_ls.config({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettier,
					null_ls.builtins.diagnostics.eslint,
				},
			})
			require("lspconfig")["null-ls"].setup({
				on_attach = require("config.utils").on_attach,
			})
		end,
	})

	-- {
	--   "folke/trouble.nvim",
	--   requires = "kyazdani42/nvim-web-devicons",
	--   config = function()
	--     require("trouble").setup {
	--       -- your configuration comes here
	--       -- or leave it empty to use the default settings
	--       -- refer to the configuration section below
	--     }
	--   end
	-- }

	-- use{
	-- "hrsh7th/nvim-compe",
	--   config = [[require('config.compe')]],
	-- }

	use({
		{
			"nvim-telescope/telescope.nvim",
			requires = {
				"nvim-lua/popup.nvim",
				"nvim-lua/plenary.nvim",
				"telescope-frecency.nvim",
				"telescope-fzf-native.nvim",
			},
			config = [[require('config.telescope')]],
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

	use("editorconfig/editorconfig-vim")

	use("vim-airline/vim-airline")
	use("vim-airline/vim-airline-themes")

	use("godlygeek/tabular")

	use("junegunn/vim-easy-align")

	use("tpope/vim-commentary")
	use("tpope/vim-repeat")
	use("tpope/vim-rsi")
	use("tpope/vim-surround")
	-- use 'tpope/vim-tbone'

	use("rust-lang/rust.vim")
end)
