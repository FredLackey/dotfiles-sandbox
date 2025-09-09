-- Colorscheme Configuration
-- Theme and color settings

return {
  -- Tokyo Night theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
        },
      })
      -- Set colorscheme
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
}