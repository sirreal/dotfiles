local function isDarkMode()
	return os.execute("defaults read -globalDomain AppleInterfaceStyle 1> /dev/null 2> /dev/null")
		== 0
end

if isDarkMode() then
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

	"subnut/nvim-ghost.nvim",

	-- Highlights
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("plugins.treesitter")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("plugins.treesitter-textobjects")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("treesitter-context")
		end,
	},

	--
	-- LSP
	--

	{
		"creativenull/efmls-configs-nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			-- "ray-x/lsp_signature.nvim",
		},
		config = function()
			require("plugins.lsp")
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

	--
	-- Completion
	--

	{
		"github/copilot.vim",
		branch = "release",
		cmd = "Copilot",
		config = function()
			vim.keymap.set("i", "<Leader><Tab>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})
			vim.g.copilot_no_tab_map = true
			-- vim.g.copilot_filetypes = {
			--       \ '*': v:false,
			--       \ 'python': v:true,
			--       \ }
		end,
		ft = {
			"javascript",
			"php",
			"typescript",
			"typescriptreact",
		},
	},

	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	config = function()
	-- 		require("copilot").setup({
	-- 			suggestion = { enabled = false },
	-- 			panel = { enabled = false },
	-- 		})
	-- 	end,
	-- },
	-- {
	-- 	"zbirenbaum/copilot-cmp",
	-- 	dependencies = {
	-- 		"zbirenbaum/copilot.lua",
	-- 	},
	-- 	config = function()
	-- 		require("copilot_cmp").setup()
	-- 	end,
	-- },

	-- {
	-- 	"supermaven-inc/supermaven-nvim",
	-- 	config = function()
	-- 		require("supermaven-nvim").setup({
	-- 			keymaps = {
	-- 				accept_suggestion = "<Leader><Tab>",
	-- 				-- clear_suggestion = "<C-]>",
	-- 				-- accept_word = "<C-j>",
	-- 			},
	-- 			disable_inline_completion = false, -- disables inline completion for use with cmp
	-- 			disable_keymaps = false, -- disables built in keymaps for more manual control
	-- 		})
	-- 	end,
	-- },
	--
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- "zbirenbaum/copilot-cmp",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"neovim/nvim-lspconfig",
			"onsails/lspkind-nvim",
		},
		config = function()
			require("plugins.cmp")
		end,
	},

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
		branch = "main",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup()
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { --[["branch",]]
						"diff",
						"diagnostics",
					},
					lualine_c = { "filename" },
					lualine_x = { --[["encoding", "fileformat",]]
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	"godlygeek/tabular",
	"junegunn/vim-easy-align",
	"tpope/vim-fugitive",
	"tpope/vim-repeat",
	"tpope/vim-rsi",
	"tpope/vim-surround",
	"tpope/vim-eunuch",
})
