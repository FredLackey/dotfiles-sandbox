-- Core configuration modules initialization

-- Load editor options first
pcall(require, 'config.options')

-- Load key mappings
pcall(require, 'config.keymaps')

-- Load plugin manager (lazy.nvim)
pcall(require, 'config.lazy')

-- Load auto commands last (and safely)
-- Defer autocmds to avoid conflicts with vim runtime files
vim.defer_fn(function()
  pcall(require, 'config.autocmds')
end, 100)