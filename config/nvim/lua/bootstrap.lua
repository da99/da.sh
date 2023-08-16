
  local function clone_paq()
    local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
    local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
    if not is_installed then
      vim.fn.system { "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path }
      return true
    end
  end

  local function headless_paq()
     local packages = {
      "savq/paq-nvim", -- let paq manage itself
      "rktjmp/lush.nvim",
      "uloco/bluloco.nvim",
      'tpope/vim-sensible',
      'folke/which-key.nvim',
      -- 'nathom/filetype.nvim',
      -- 'simrat39/symbols-outline.nvim',
      "vim-crystal/vim-crystal",

      -- Terminal-related:
      'kassio/neoterm',

      -- Common:
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'neovim/nvim-lspconfig',

      -- Mason.nvim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- mini statusline
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
      { 'echasnovski/mini.nvim', branch = 'main' },

      -- telescope
      'burntsushi/ripgrep',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
      },
      'nvim-telescope/telescope.nvim',

      -- tree-sitter
      { 'nvim-treesitter/nvim-treesitter', run = ':TSupdate' },

      -- Neo-tree
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x", }
    }

    local first_install = clone_paq()
    vim.cmd.packadd("paq-nvim")
    local paq = require("paq")
    if first_install then
      vim.notify("Installing plugins... If prompted, hit Enter to continue.")
    end

    -- Set to exit nvim after installing plugins
    vim.cmd("autocmd User PaqDoneInstall quit")
    -- Read and install packages
    paq(packages)
    paq.clean()
    paq.update()
    paq.install()
    -- paq.sync()
  end

  return {
    headless_paq = headless_paq,
  }
