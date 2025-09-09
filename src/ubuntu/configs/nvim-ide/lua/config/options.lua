-- Editor Options
-- Core Neovim settings for IDE functionality

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.completeopt = "menu,menuone,noselect"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of word
opt.iskeyword:append("-")

-- Disable swapfile
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Undo persistence
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Update time
opt.updatetime = 50

-- Timeout
opt.timeoutlen = 300

-- Better completion experience
opt.pumheight = 10

-- Always show tabs
opt.showtabline = 2

-- Don't show mode since we have a statusline
opt.showmode = false

-- Enable mouse support
opt.mouse = "a"

-- Fold settings (using treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel = 99