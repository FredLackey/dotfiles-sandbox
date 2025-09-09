-- Core configuration modules initialization

-- Load editor options first
require('config.options')

-- Load key mappings
require('config.keymaps')

-- Load plugin manager (lazy.nvim)
require('config.lazy')

-- Load auto commands
require('config.autocmds')