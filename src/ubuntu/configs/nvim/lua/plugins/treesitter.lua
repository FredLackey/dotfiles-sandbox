-- Simplified Treesitter Configuration
-- Minimal setup to avoid compilation errors on first run

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  priority = 100,
  config = function()
    -- Safely try to setup treesitter
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
      -- Treesitter not available yet, skip configuration
      return
    end
    
    -- Minimal configuration with no automatic parser installation
    configs.setup({
      -- Empty ensure_installed to avoid automatic compilation
      ensure_installed = {},
      
      -- Disable automatic installation
      auto_install = false,
      
      -- Enable basic highlighting if parsers are available
      highlight = {
        enable = true,
        disable = function(lang, buf)
          -- Disable for large files
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
      
      -- Basic indentation
      indent = {
        enable = true,
        disable = { "yaml" }, -- YAML indentation can be problematic
      },
    })
    
    -- Create user command to install parsers manually
    vim.api.nvim_create_user_command("TSInstallBasic", function()
      -- Install only the most basic parsers
      vim.cmd("TSInstall lua")
      vim.cmd("TSInstall vim")
      vim.cmd("TSInstall vimdoc")
    end, { desc = "Install basic Treesitter parsers" })
    
    vim.api.nvim_create_user_command("TSInstallWeb", function()
      -- Install web development parsers
      vim.cmd("TSInstall javascript")
      vim.cmd("TSInstall typescript")
      vim.cmd("TSInstall html")
      vim.cmd("TSInstall css")
      vim.cmd("TSInstall json")
    end, { desc = "Install web development Treesitter parsers" })
    
    vim.api.nvim_create_user_command("TSInstallAll", function()
      -- Install all common parsers
      vim.cmd("TSInstall bash")
      vim.cmd("TSInstall python")
      vim.cmd("TSInstall java")
      vim.cmd("TSInstall yaml")
      vim.cmd("TSInstall markdown")
      vim.cmd("TSInstall dockerfile")
    end, { desc = "Install all common Treesitter parsers" })
  end,
}