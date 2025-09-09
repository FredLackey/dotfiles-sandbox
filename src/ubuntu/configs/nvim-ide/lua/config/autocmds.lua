-- Auto Commands
-- Automatic behaviors for specific events

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings
local general = augroup("UserGeneral", { clear = true })

-- Highlight yanked text
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Check if file changed outside of Neovim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = general,
  command = "checktime",
})

-- Auto-resize splits when terminal is resized
autocmd("VimResized", {
  group = general,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last location when opening a file
autocmd("BufReadPost", {
  group = general,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- File type specific settings
local filetype = augroup("UserFileType", { clear = true })

-- Set tab width for specific file types
autocmd("FileType", {
  group = filetype,
  pattern = { "python", "rust", "go", "java" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Enable wrap for markdown and text files
autocmd("FileType", {
  group = filetype,
  pattern = { "markdown", "text", "txt" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Set specific options for JSON files
autocmd("FileType", {
  group = filetype,
  pattern = "json",
  callback = function()
    vim.opt_local.conceallevel = 0
    vim.opt_local.formatoptions:remove({ "t" })
  end,
})

-- Terminal settings
local terminal = augroup("UserTerminal", { clear = true })

-- Start terminal in insert mode
autocmd("TermOpen", {
  group = terminal,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

-- Close terminal buffer on process exit
autocmd("BufLeave", {
  group = terminal,
  pattern = "term://*",
  callback = function()
    vim.cmd("stopinsert")
  end,
})

-- Auto-save
local autosave = augroup("UserAutoSave", { clear = true })

-- Save on focus lost (optional, disabled by default)
-- Uncomment to enable
-- autocmd({ "FocusLost", "BufLeave" }, {
--   group = autosave,
--   callback = function()
--     if vim.bo.modified and vim.bo.buftype == "" then
--       vim.cmd("silent! write")
--     end
--   end,
-- })

-- LSP formatting
local lsp_format = augroup("UserLspFormat", { clear = true })

-- Format on save for specific file types
autocmd("BufWritePre", {
  group = lsp_format,
  pattern = {
    "*.js",
    "*.jsx",
    "*.ts",
    "*.tsx",
    "*.json",
    "*.css",
    "*.scss",
    "*.html",
    "*.md",
    "*.lua",
    "*.py",
    "*.go",
    "*.rs",
  },
  callback = function()
    -- Only format if LSP client supports it
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in pairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false })
        return
      end
    end
  end,
})

-- Auto-create parent directories when saving
autocmd("BufWritePre", {
  group = general,
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})