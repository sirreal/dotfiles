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
		"catppuccin/nvim",
		as = "catppuccin",
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
		"nvimdev/lspsaga.nvim",
		after = "nvim-lspconfig",
		config = function()
			require("lspsaga").setup({
				ui = {
					kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
				},
			})
		end,
	})

	-- Linting, autoformatting…
	use({
		"nvimdev/guard.nvim",
		requires = {
			"nvimdev/guard-collection",
		},
		config = function()
			local ft = require("guard.filetype")
			local guard_formatters = require("guard-collection.formatter")

			ft("lua"):fmt(guard_formatters.stylua)

			ft(table.concat({
				"css",
				"dockerfile",
				"javascript",
				"javascriptreact",
				"json",
				"json5",
				"jsonc",
				"markdown",
				"sass",
				"scss",
				"toml",
				"typescript",
				"typescriptreact",
			}, ",")):fmt(guard_formatters.dprint)

			require("guard").setup({
				fmt_on_save = true,
			})
		end,
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
			"nvim-lua/plenary.nvim",
		},
		config = [[require("plugins.telescope")]],
		cmd = "Telescope",
		module = "telescope",
	})

	--
	-- Git
	--

	use({
		"lewis6991/gitsigns.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup()
		end,
	})

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
					theme = "catppuccin",
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
