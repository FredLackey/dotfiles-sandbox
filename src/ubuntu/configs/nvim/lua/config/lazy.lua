-- Plugin Manager Configuration (lazy.nvim)
-- Bootstrap and configure the lazy.nvim plugin manager

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins directory
require("lazy").setup("plugins", {
  defaults = { 
    lazy = true -- Lazy load plugins by default
  },
  install = { 
    -- Colorschemes to try when installing missing plugins
    colorscheme = { "tokyonight", "habamax" } 
  },
  checker = { 
    enabled = true,  -- Automatically check for updates
    notify = false   -- Don't notify about updates
  },
  change_detection = { 
    enabled = true,  -- Auto-reload on config change
    notify = false   -- Don't notify about config changes
  },
  performance = {
    rtp = {
      -- Disable some built-in plugins for better performance
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})