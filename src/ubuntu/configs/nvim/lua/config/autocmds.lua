-- Auto Commands
-- Automatic behaviors for specific events

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General settings
local general = augroup("General", { clear = true })

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
  group = general,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when terminal is resized
autocmd("VimResized", {
  group = general,
  pattern = "*",
  command = "wincmd =",
})

-- File type specific settings
local filetype = augroup("FileType", { clear = true })

-- Set tab width for specific file types
autocmd("FileType", {
  group = filetype,
  pattern = { "python", "rust", "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Enable wrap for markdown files
autocmd("FileType", {
  group = filetype,
  pattern = { "markdown", "txt" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Terminal settings
local terminal = augroup("Terminal", { clear = true })

-- Start terminal in insert mode
autocmd("TermOpen", {
  group = terminal,
  pattern = "*",
  command = "startinsert",
})

-- No line numbers in terminal
autocmd("TermOpen", {
  group = terminal,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})