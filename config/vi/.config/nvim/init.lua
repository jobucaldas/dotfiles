vim.g.loaded_node_provider=0;vim.g.loaded_perl_provider=0;vim.g.loaded_ruby_provider=0;vim.g.loaded_python3_provider=0
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

local kitty_bg = "#000000"
local kitty_surface = "#1f1a20"

local minibase16_palette = {
  base00 = "#141218",
  base01 = "#1f1a20",
  base02 = "#2a2430",
  base03 = "#9d99a5",
  base04 = "#cac4cf",
  base05 = "#e6e0e9",
  base06 = "#f4efff",
  base07 = "#faf8ff",
  base08 = "#ff728f",
  base09 = "#ff9fb2",
  base0A = "#ffda72",
  base0B = "#7fff9a",
  base0C = "#d0bcff",
  base0D = "#bca5f2",
  base0E = "#ded0ff",
  base0F = "#4e3d76",
}

local function apply_kitty_background()
  local groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "FoldColumn",
    "LineNr",
    "EndOfBuffer",
    "NvimTreeNormal",
    "NvimTreeNormalNC",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = kitty_bg })
  end

  vim.api.nvim_set_hl(0, "NormalFloat", { bg = kitty_surface })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = kitty_surface })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = kitty_surface })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_kitty_background,
})

local function load_minibase16()
  require("mini.base16").setup({
    palette = minibase16_palette,
  })
  apply_kitty_background()
end

local function force_line_numbers()
  vim.opt.number = true
  vim.opt.relativenumber = false

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.wo[win].number = true
    vim.wo[win].relativenumber = false
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "BufWinEnter", "WinEnter" }, {
  callback = force_line_numbers,
})

apply_kitty_background()

require("lazy").setup({
  spec = {
    -- LazyVim base distro
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    
    {
      "nvim-mini/mini.nvim",
      version = false,
      lazy = false,
      priority = 1000,
    },

    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = load_minibase16,
      },
    },

    -- Use nvim-cmp instead of LazyVim default blink.cmp
    { import = "lazyvim.plugins.extras.coding.nvim-cmp" },

    -- Nix: treesitter nix + nil_ls + nixfmt + statix
    { import = "lazyvim.plugins.extras.lang.nix" },

    -- GitHub Copilot
    { import = "lazyvim.plugins.extras.ai.copilot" },

    -- Nix provides LSPs/tools. Mason stays available, but no auto-install.
    {
      "mason-org/mason.nvim",
      opts = {
        ensure_installed = {},
      },
    },
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {},
      },
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          ["*"] = {
            mason = false,
          },
          nil_ls = {
            mason = false,
          },
          lua_ls = {
            mason = false,
          },
        },
      },
    },

    -- File sidebar
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
        { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file" },
      },
      opts = {
        view = {
          width = 32,
          side = "left",
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      },
    },
  },

  defaults = {
    lazy = false,
    version = false,
  },

  install = {
    colorscheme = { "tokyonight", "habamax" },
  },

  checker = {
    enabled = false,
  },
})

force_line_numbers()
