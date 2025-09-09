-- Core configuration modules initialization

-- Load basic options first
require('config.options')

-- Load key mappings
require('config.keymaps')

-- Load plugin manager (lazy.nvim)
require('config.lazy')

-- Load auto commands
vim.defer_fn(function()
  require('config.autocmds')
end, 100)