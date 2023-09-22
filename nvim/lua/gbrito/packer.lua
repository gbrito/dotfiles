vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'christoomey/vim-tmux-navigator'
  use 'stevearc/dressing.nvim'

  use {
	  'nvim-tree/nvim-tree.lua',
	  requires = {
            {'nvim-tree/nvim-web-devicons'},
        }
  }

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.0',
	  requires = {
            {'nvim-lua/plenary.nvim'},
            {'nvim-tree/nvim-web-devicons'},
        }
  }

  use({
	  'rose-pine/neovim',
	  as = 'rose-pine',
	  config = function()
		  vim.cmd('colorscheme rose-pine')
	  end
  })

  use({
      "folke/trouble.nvim",
      config = function()
          require("trouble").setup {
              icons = false,
          }
      end
  })

  use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
          local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
          ts_update()
      end,
  }

  use("nvim-treesitter/playground")
  use("theprimeagen/harpoon")
  use("theprimeagen/refactoring.nvim")
  use("mbbill/undotree")
  use("tpope/vim-fugitive")
  use("nvim-treesitter/nvim-treesitter-context");

  use {
      'numToStr/Comment.nvim',
      config = function()
          require('Comment').setup()
      end
  }

  use {
      'williamboman/mason.nvim',
      requires = {
          "williamboman/mason-lspconfig.nvim",
      }
  }

  use {
	  "hrsh7th/nvim-cmp",
	  requires = {
          "neovim/nvim-lspconfig",
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "antosha417/nvim-lsp-file-operations",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
	  }
  }

end)
