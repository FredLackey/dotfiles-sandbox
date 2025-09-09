-- Minimal Auto Commands
-- Simple automatic behaviors without conflicts

-- Only create autocmds if the API is available
if not vim.api or not vim.api.nvim_create_autocmd then
  return
end

-- Wrap everything in pcall to handle any errors gracefully
pcall(function()
  local augroup = vim.api.nvim_create_augroup
  
  -- Create a unique group name to avoid conflicts
  local group = augroup("UserConfig", { clear = true })
  
  -- Highlight yanked text (this is usually safe)
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      vim.highlight.on_yank({ timeout = 200 })
    end,
  })
  
  -- Set specific options for Python files
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    callback = function()
      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
    end,
  })
  
  -- Set specific options for Markdown files
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
    end,
  })
end)