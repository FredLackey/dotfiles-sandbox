-- Key Mappings for Neovim
-- Core keyboard shortcuts and bindings

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
keymap.set("n", "<C-Up>", ":resize +2<CR>", opts)
keymap.set("n", "<C-Down>", ":resize -2<CR>", opts)
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer navigation
keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<leader>bd", ":bdelete<CR>", opts)

-- Stay in indent mode
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Move text up and down
keymap.set("v", "J", ":move '>+1<CR>gv=gv", opts)
keymap.set("v", "K", ":move '<-2<CR>gv=gv", opts)

-- Clear search highlighting
keymap.set("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Save file
keymap.set("n", "<C-s>", ":w<CR>", opts)
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", opts)

-- Close all buffers except current
keymap.set("n", "<leader>bo", ":%bd|e#|bd#<CR>", opts)

-- Terminal
keymap.set("n", "<leader>tt", ":terminal<CR>", opts)
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

-- Better paste
keymap.set("v", "p", '"_dP', opts)

-- Quick quit
keymap.set("n", "<leader>qq", ":qa<CR>", opts)

-- Split windows
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts)
keymap.set("n", "<leader>sh", ":split<CR>", opts)