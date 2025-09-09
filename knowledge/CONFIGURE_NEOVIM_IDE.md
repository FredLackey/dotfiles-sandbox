# Configuring Neovim as a Full-Featured IDE for Node.js, JavaScript, and Java Development

This document outlines how to transform Neovim into a powerful IDE for Node.js, JavaScript, TypeScript, and Java development, with a layout and functionality similar to VSCode.

## Table of Contents
1. [Core Components](#core-components)
2. [JavaScript/TypeScript/Node.js Setup](#javascripttypescriptnodejs-setup)
3. [Java Development Setup](#java-development-setup)
4. [VSCode-like Layout](#vscode-like-layout)
5. [Debugging Configuration](#debugging-configuration)
6. [Additional IDE Features](#additional-ide-features)
7. [Recommended Plugin Configurations](#recommended-plugin-configurations)

## Core Components

### Plugin Manager
- **lazy.nvim** - Modern plugin manager with lazy loading capabilities
- Alternative: **packer.nvim** (deprecated but still functional)

### LSP (Language Server Protocol)
- **nvim-lspconfig** - Official LSP configuration plugin
- **mason.nvim** - Portable package manager for LSP servers, DAP servers, linters, and formatters
- **mason-lspconfig.nvim** - Bridge between mason.nvim and lspconfig

### Auto-completion
- **nvim-cmp** - Completion engine
- **cmp-nvim-lsp** - LSP source for nvim-cmp
- **cmp-buffer** - Buffer words source
- **cmp-path** - Filesystem paths source
- **LuaSnip** - Snippet engine
- **lspkind.nvim** - VSCode-like pictograms in completion menu

### Syntax Highlighting
- **nvim-treesitter** - Advanced syntax highlighting and code understanding
- Requires: build-essential package for compiling parsers

## JavaScript/TypeScript/Node.js Setup

### Required Language Servers
```bash
# Install via npm globally or using Mason
npm install -g typescript typescript-language-server
npm install -g @tailwindcss/language-server
npm install -g vscode-langservers-extracted  # For ESLint, HTML, CSS, JSON
```

### LSP Configuration
```lua
-- TypeScript/JavaScript
require('lspconfig').tsserver.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  cmd = { "typescript-language-server", "--stdio" },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
      }
    }
  }
})

-- ESLint
require('lspconfig').eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})
```

### Formatting
- **prettier.nvim** - Prettier integration
- **null-ls.nvim** (deprecated) or **none-ls.nvim** (maintained fork) - Use external formatters
- **conform.nvim** - Modern formatting plugin (recommended)

```lua
-- Using conform.nvim for formatting
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
```

### Linting
- **nvim-lint** - Asynchronous linting
- Integrates with ESLint, JSHint, StandardJS

## Java Development Setup

### Option 1: nvim-java (Recommended for Simplicity)
**nvim-java** provides an all-in-one solution with automatic setup:

```lua
-- Setup nvim-java BEFORE lspconfig
require('java').setup()

-- Then setup jdtls
require('lspconfig').jdtls.setup({})
```

Features:
- Automatic installation of JDTLS, Lombok, Java Debug Adapter
- Spring Boot support built-in
- Test runner integration
- Automatic DAP configuration
- Maven and Gradle support

### Option 2: nvim-jdtls (For Advanced Users)
For users who prefer manual configuration and more control.

### Java-specific Features
- **Debugging**: Automatic debug configuration with nvim-dap
- **Testing**: Run/debug JUnit and TestNG tests
- **Build Tools**: Maven and Gradle integration
- **Spring Boot**: Enhanced support with spring-boot-tools
- **Refactoring**: Extract variable/method/constant, organize imports

## VSCode-like Layout

### File Explorer
**neo-tree.nvim** (Recommended) - Modern file explorer with many features:
```lua
require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  window = {
    position = "left",
    width = 30,
  },
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
  },
})
```

Alternative: **nvim-tree.lua** - Simpler, lightweight file explorer

### Tab/Buffer Management
- **bufferline.nvim** - VSCode-like tabs
- **barbar.nvim** - Alternative tabline plugin

```lua
require("bufferline").setup({
  options = {
    mode = "buffers",
    separator_style = "thin",
    always_show_bufferline = true,
    show_buffer_close_icons = true,
    show_close_icon = false,
    color_icons = true,
    diagnostics = "nvim_lsp",
  }
})
```

### Status Line
- **lualine.nvim** - Customizable statusline
- Shows git branch, diagnostics, file info, cursor position

### Fuzzy Finder
- **telescope.nvim** - Extensible fuzzy finder
- Find files, search text, browse git commits
- Similar to VSCode's Ctrl+P and Ctrl+Shift+F

```lua
require('telescope').setup({
  defaults = {
    layout_config = {
      horizontal = {
        preview_width = 0.6,
      },
    },
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      hijack_netrw = true,
    },
  },
})
```

## Debugging Configuration

### nvim-dap Setup
Core debugging functionality similar to VSCode's debugger:

```lua
local dap = require('dap')

-- JavaScript/TypeScript debugging
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      require('mason-registry').get_package('js-debug-adapter'):get_install_path()
        .. '/js-debug/src/dapDebugServer.js',
      "${port}",
    },
  },
}

dap.configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach",
    processId = require('dap.utils').pick_process,
    cwd = "${workspaceFolder}",
  },
}
```

### DAP UI
- **nvim-dap-ui** - VSCode-like debugging UI
- Shows variables, call stack, breakpoints, console

```lua
require("dapui").setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      position = "left",
      size = 40,
    },
    {
      elements = {
        { id = "repl", size = 0.5 },
        { id = "console", size = 0.5 },
      },
      position = "bottom",
      size = 10,
    },
  },
})
```

## Additional IDE Features

### Git Integration
- **gitsigns.nvim** - Git decorations and blame
- **diffview.nvim** - VSCode-like diff viewer
- **neogit** or **fugitive.vim** - Git operations

### Terminal Integration
- **toggleterm.nvim** - Better terminal management
- Floating, vertical, or horizontal terminals

### Code Actions and Refactoring
- **lspsaga.nvim** - Enhanced LSP UIs
- Beautiful hover docs, definition preview, rename UI

### Diagnostics
- **trouble.nvim** - Pretty diagnostics list
- **lsp_lines.nvim** - Show diagnostics inline

### Project Management
- **project.nvim** - Automatic project detection
- **neoconf.nvim** - Per-project LSP settings

## Recommended Plugin Configurations

### Essential Plugin List
```lua
-- Using lazy.nvim
return {
  -- Core
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  
  -- Completion
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'L3MON4D3/LuaSnip',
  'onsails/lspkind.nvim',
  
  -- UI
  'nvim-neo-tree/neo-tree.nvim',
  'nvim-lualine/lualine.nvim',
  'akinsho/bufferline.nvim',
  'nvim-telescope/telescope.nvim',
  
  -- Syntax
  'nvim-treesitter/nvim-treesitter',
  
  -- Formatting/Linting
  'stevearc/conform.nvim',
  'mfussenegger/nvim-lint',
  
  -- Debugging
  'mfussenegger/nvim-dap',
  'rcarriga/nvim-dap-ui',
  'theHamsta/nvim-dap-virtual-text',
  
  -- Git
  'lewis6991/gitsigns.nvim',
  'sindrets/diffview.nvim',
  
  -- Java
  'nvim-java/nvim-java',
  
  -- Utilities
  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',
  'numToStr/Comment.nvim',
  'folke/which-key.nvim',
  'folke/trouble.nvim',
}
```

### Keybindings for VSCode Users
```lua
-- File Explorer
vim.keymap.set('n', '<C-b>', ':Neotree toggle<CR>')

-- Find files (Ctrl+P in VSCode)
vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>')

-- Search in files (Ctrl+Shift+F in VSCode)
vim.keymap.set('n', '<C-S-f>', ':Telescope live_grep<CR>')

-- Go to definition (F12 in VSCode)
vim.keymap.set('n', '<F12>', vim.lsp.buf.definition)

-- Show hover info (hover in VSCode)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)

-- Rename symbol (F2 in VSCode)
vim.keymap.set('n', '<F2>', vim.lsp.buf.rename)

-- Format document (Shift+Alt+F in VSCode)
vim.keymap.set('n', '<S-A-f>', vim.lsp.buf.format)

-- Toggle terminal
vim.keymap.set('n', '<C-`>', ':ToggleTerm<CR>')
```

## Performance Tips

1. **Lazy Loading**: Use lazy.nvim's lazy loading features
2. **Treesitter**: Only install parsers for languages you use
3. **LSP**: Disable features you don't need (e.g., semantic tokens)
4. **Startup**: Profile startup time with `:StartupTime`

## Troubleshooting

### Common Issues
1. **Treesitter compilation errors**: Install `build-essential` (Ubuntu) or equivalent
2. **LSP not starting**: Check `:LspInfo` and `:Mason`
3. **Slow performance**: Disable unused plugins, reduce Treesitter parsers
4. **Java setup issues**: Ensure JDK is installed, use `:JavaProfile` to switch JDK versions

### Useful Commands
- `:checkhealth` - Check Neovim and plugin health
- `:LspInfo` - Show LSP status
- `:Mason` - Manage LSP servers and tools
- `:TSInstallInfo` - Show Treesitter parser status