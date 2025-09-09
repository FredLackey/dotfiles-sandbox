-- Treesitter Configuration
-- Advanced syntax highlighting and code understanding

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    -- Disable auto-tag initially to avoid errors
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if not ok then
      vim.notify("Treesitter not found!", vim.log.levels.ERROR)
      return
    end
    
    configs.setup({
      -- Start with minimal parsers that usually compile without issues
      ensure_installed = {
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
      },
      -- Don't auto-install to avoid compilation errors on first run
      auto_install = false,
      -- Install parsers synchronously (only applied to ensure_installed)
      sync_install = false,
      -- Syntax highlighting
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      -- Indentation based on treesitter
      indent = { 
        enable = true 
      },
      -- Incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-backspace>",
        },
      },
      -- Text objects
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    })
  end,
}