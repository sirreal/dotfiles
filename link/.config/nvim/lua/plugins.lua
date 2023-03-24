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
      if "Dark" == io.popen("defaults read -g AppleInterfaceStyle", "r"):read() then
        require("tokyonight").setup({ style = "storm" })
        vim.cmd([[colorscheme tokyonight-storm]])
      else
        require("tokyonight").setup({ style = "day" })
        vim.cmd([[colorscheme tokyonight-day]])
      end
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

  --
  -- Copilot
  --
  use({ "github/copilot.vim", git_branch = "release" })

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
    -- "glepnir/lspsaga.nvim",
    "kkharji/lspsaga.nvim", -- temporary maintenance fork
    requires = { "neovim/nvim-lspconfig" },
    config = function()
      require("lspsaga").init_lsp_saga({
        debug = false,
        use_saga_diagnostic_sign = true,
        error_sign = "",
        warn_sign = "",
        hint_sign = "",
        infor_sign = "",
        -- code_action_icon = "\u{fd1e}",
        diagnostic_header_icon = "  ",
      })
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
    "kyazdani42/nvim-web-devicons",
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
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
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
        -- "nvim-telescope/telescope-frecency.nvim",
        -- "nvim-telescope/telescope-fzf-native.nvim",
      },
      config = [[require("plugins.telescope")]],
      cmd = "Telescope",
      module = "telescope",
    },
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
  use({
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  })
  use({
    "TimUntersberger/neogit",
    cmd = "Neogit",
    disable = true,
  })

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
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
