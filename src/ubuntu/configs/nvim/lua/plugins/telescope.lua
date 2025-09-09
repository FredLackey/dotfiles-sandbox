-- Telescope Configuration
-- Fuzzy finder for files, buffers, and more

return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Find string under cursor" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>ft", "<cmd>Telescope filetypes<cr>", desc = "File types" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    
    telescope.setup({
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<Esc>"] = actions.close,
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          previewer = false,
          hidden = true,
        },
        buffers = {
          theme = "dropdown",
          previewer = false,
          initial_mode = "normal",
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    
    -- Load extensions
    if vim.fn.executable("make") == 1 then
      telescope.load_extension("fzf")
    end
  end,
}