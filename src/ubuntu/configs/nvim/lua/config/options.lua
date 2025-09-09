-- Neovim Editor Options
-- Core settings for the editor

local opt = vim.opt

-- Line numbers
opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Relative line numbers
opt.numberwidth = 4          -- Number column width

-- Tabs and indentation
opt.tabstop = 2              -- Number of spaces per tab
opt.shiftwidth = 2           -- Spaces for each indentation
opt.expandtab = true         -- Convert tabs to spaces
opt.autoindent = true        -- Copy indent from current line
opt.smartindent = true       -- Smart indentation

-- Search
opt.ignorecase = true        -- Case insensitive search
opt.smartcase = true         -- Case sensitive if uppercase
opt.hlsearch = true          -- Highlight search results
opt.incsearch = true         -- Incremental search

-- Appearance
opt.termguicolors = true     -- True color support
opt.signcolumn = "yes"       -- Always show sign column
opt.cursorline = true        -- Highlight current line
opt.wrap = false             -- Disable line wrap
opt.scrolloff = 8            -- Lines to keep above/below cursor
opt.sidescrolloff = 8        -- Columns to keep left/right of cursor

-- Behavior
opt.mouse = "a"              -- Enable mouse support
opt.clipboard = "unnamedplus" -- System clipboard
opt.splitbelow = true        -- Horizontal splits below
opt.splitright = true        -- Vertical splits to the right
opt.undofile = true          -- Persistent undo
opt.updatetime = 300         -- Faster completion
opt.timeoutlen = 300         -- Time to wait for mapped sequence

-- Completion
opt.completeopt = "menuone,noselect" -- Better completion experience
opt.pumheight = 10           -- Maximum items in popup menu

-- Backup
opt.backup = false           -- No backup files
opt.writebackup = false      -- No backup before overwriting
opt.swapfile = false         -- No swap files

-- File encoding
opt.encoding = "utf-8"       -- UTF-8 encoding
opt.fileencoding = "utf-8"   -- File encoding