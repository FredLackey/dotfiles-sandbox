# Neovim Configuration for Node.js and Java Developers

## Overview

Neovim is a hyperextensible text editor that builds upon Vim's foundation, providing powerful features for modern development. This document provides comprehensive instructions for installing and configuring Neovim as a full-featured IDE for Node.js, JavaScript, TypeScript, and Java development on Ubuntu Server, Ubuntu WSL, and macOS.

## Prerequisites

- **ZSH already installed and configured** (see CONFIGURE_ZSH.md)
- **Oh My Zsh framework installed** (see CONFIGURE_OMYYZSH.md)
- **Git installed** for cloning plugins and configurations
- **Node.js and npm** for JavaScript/TypeScript language servers
- **Java JDK** for Java development support
- **C compiler** for compiling native extensions
- **Python 3 with pip** for some plugin dependencies
- **curl or wget** for downloading resources

## Installation

### Ubuntu Server and Ubuntu WSL

#### Step 1: Add Neovim Repository (for latest stable version)

```bash
# Option 1: Using the official PPA (recommended for Ubuntu)
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update

# Option 2: Using snap (alternative)
sudo snap install nvim --classic
```

#### Step 2: Install Neovim and Dependencies

```bash
# Install Neovim
sudo apt install neovim

# Install build essentials for native compilation
sudo apt install build-essential

# Install Python support
sudo apt install python3 python3-pip
pip3 install --user pynvim

# Install Node.js support
npm install -g neovim

# Install ripgrep for fast searching
sudo apt install ripgrep

# Install fd for file finding
sudo apt install fd-find

# Create fd symlink (Ubuntu names it fdfind)
ln -s $(which fdfind) ~/.local/bin/fd
```

### macOS Installation

#### Step 1: Install Using Homebrew

```bash
# Install Neovim
brew install neovim

# Install Python support
pip3 install pynvim

# Install Node.js support
npm install -g neovim

# Install ripgrep for fast searching
brew install ripgrep

# Install fd for file finding
brew install fd

# Install tree-sitter CLI (for parser generation)
brew install tree-sitter
```

#### Step 2: Install Additional Tools

```bash
# Install universal-ctags for code navigation
brew install --HEAD universal-ctags

# Install the silver searcher (alternative to ripgrep)
brew install the_silver_searcher
```

### WSL-Specific Setup

For WSL environments, ensure proper clipboard integration:

```bash
# Install clipboard utilities
sudo apt install xclip xsel

# Install win32yank for Windows clipboard integration
# Download from GitHub releases
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/
```

## Configuration Structure

Neovim uses a modular configuration structure:

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── config/
│   │   ├── init.lua         # Module initialization
│   │   ├── options.lua      # Editor options
│   │   ├── keymaps.lua      # Key mappings
│   │   ├── autocmds.lua     # Auto commands
│   │   └── lazy.lua         # Plugin manager setup
│   └── plugins/
│       ├── core/            # Core functionality plugins
│       ├── lsp/             # Language server configurations
│       ├── completion/      # Auto-completion setup
│       ├── ui/              # UI enhancements
│       └── tools/           # Development tools
└── after/
    └── ftplugin/            # File type specific settings
```

## Initial Setup

### Step 1: Create Configuration Directory

```bash
# Create Neovim config directory
mkdir -p ~/.config/nvim/lua/config
mkdir -p ~/.config/nvim/lua/plugins
```

### Step 2: Create Main Configuration File

Create `~/.config/nvim/init.lua`:

```lua
-- Load core configuration
require('config')
```

### Step 3: Create Module Initialization

Create `~/.config/nvim/lua/config/init.lua`:

```lua
-- Core configuration modules
require('config.options')    -- Editor options
require('config.keymaps')    -- Key mappings
require('config.lazy')       -- Plugin manager
require('config.autocmds')   -- Auto commands
```

## Plugin Manager Setup (lazy.nvim)

### Installing lazy.nvim

Create `~/.config/nvim/lua/config/lazy.lua`:

```lua
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

-- Load plugins
require("lazy").setup("plugins", {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight", "catppuccin" } },
  checker = { enabled = true, notify = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = {
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
```

## Core Editor Options

Create `~/.config/nvim/lua/config/options.lua`:

```lua
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
```

## Essential Plugins

### Core Plugin Configuration Structure

Create plugin configuration files in `~/.config/nvim/lua/plugins/`:

### 1. Treesitter (Syntax Highlighting)

Create `~/.config/nvim/lua/plugins/treesitter.lua`:

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash", "c", "cpp", "css", "dockerfile",
        "go", "html", "java", "javascript", "json",
        "lua", "markdown", "python", "rust", "tsx",
        "typescript", "vim", "vimdoc", "yaml"
      },
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<C-backspace>",
        },
      },
    })
  end,
}
```

### 2. LSP Configuration

Create `~/.config/nvim/lua/plugins/lsp/init.lua`:

```lua
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Configure language servers
      mason_lspconfig.setup({
        ensure_installed = {
          "tsserver",        -- TypeScript/JavaScript
          "eslint",          -- JavaScript linter
          "html",            -- HTML
          "cssls",           -- CSS
          "jsonls",          -- JSON
          "yamlls",          -- YAML
          "jdtls",           -- Java
          "lua_ls",          -- Lua
          "bashls",          -- Bash
          "dockerls",        -- Docker
          "marksman",        -- Markdown
        },
      })

      -- Setup handlers
      mason_lspconfig.setup_handlers({
        -- Default handler
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,

        -- TypeScript/JavaScript specific config
        ["tsserver"] = function()
          lspconfig.tsserver.setup({
            capabilities = capabilities,
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                },
              },
            },
          })
        end,

        -- Java specific config (handled by nvim-jdtls plugin)
        ["jdtls"] = function()
          -- Skip, will be configured by nvim-jdtls
        end,
      })
    end,
  },

  -- Mason (Package Manager for LSP servers)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
}
```

### 3. Java Development Support

Create `~/.config/nvim/lua/plugins/lsp/java.lua`:

```lua
return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  config = function()
    local jdtls = require("jdtls")
    
    -- Find root directory
    local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
    local root_dir = require("jdtls.setup").find_root(root_markers)
    
    -- Workspace directory
    local workspace_dir = vim.fn.fnamemodify(root_dir, ":p:h:t")
    
    local config = {
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration", vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_" .. (vim.fn.has("mac") == 1 and "mac" or "linux"),
        "-data", vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. workspace_dir,
      },
      root_dir = root_dir,
      settings = {
        java = {
          eclipse = { downloadSources = true },
          maven = { downloadSources = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          format = { enabled = true },
        },
      },
      init_options = {
        bundles = {},
      },
    }
    
    jdtls.start_or_attach(config)
  end,
}
```

### 4. Auto-completion

Create `~/.config/nvim/lua/plugins/completion.lua`:

```lua
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
```

### 5. File Explorer

Create `~/.config/nvim/lua/plugins/neo-tree.lua`:

```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    { "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus file explorer" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
    })
  end,
}
```

### 6. Fuzzy Finder

Create `~/.config/nvim/lua/plugins/telescope.lua`:

```lua
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  config = function()
    local telescope = require("telescope")
    
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          previewer = false,
        },
      },
    })
    
    telescope.load_extension("fzf")
  end,
}
```

## Key Mappings

Create `~/.config/nvim/lua/config/keymaps.lua`:

```lua
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

-- Close all buffers except current
keymap.set("n", "<leader>bo", ":%bd|e#|bd#<CR>", opts)

-- Terminal
keymap.set("n", "<leader>tt", ":terminal<CR>", opts)
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
```

## Language-Specific Configurations

### JavaScript/TypeScript Development

Create `~/.config/nvim/after/ftplugin/javascript.lua` and `typescript.lua`:

```lua
-- Set tab width for JavaScript/TypeScript
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

-- Enable format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  callback = function()
    vim.lsp.buf.format()
  end,
})
```

### Java Development

Create `~/.config/nvim/after/ftplugin/java.lua`:

```lua
-- Java specific settings
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true

-- Set up keymaps for Java
local opts = { buffer = 0, noremap = true, silent = true }
vim.keymap.set("n", "<leader>co", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
vim.keymap.set("n", "<leader>cv", "<Cmd>lua require'jdtls'.extract_variable()<CR>", opts)
vim.keymap.set("v", "<leader>cv", "<Esc><Cmd>lua require'jdtls'.extract_variable(true)<CR>", opts)
vim.keymap.set("n", "<leader>cc", "<Cmd>lua require'jdtls'.extract_constant()<CR>", opts)
vim.keymap.set("v", "<leader>cc", "<Esc><Cmd>lua require'jdtls'.extract_constant(true)<CR>", opts)
vim.keymap.set("v", "<leader>cm", "<Esc><Cmd>lua require'jdtls'.extract_method(true)<CR>", opts)
```

## Additional Tools and Plugins

### Git Integration

Create `~/.config/nvim/lua/plugins/git.lua`:

```lua
return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
        },
      })
    end,
  },

  -- Fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    },
  },
}
```

### Terminal Integration

Create `~/.config/nvim/lua/plugins/toggleterm.lua`:

```lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal" },
  },
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 3,
      },
    })
  end,
}
```

## Performance Optimization

### Lazy Loading

Most plugins are configured with lazy loading to improve startup time:

- **Event-based loading**: Plugins load on specific events (BufReadPre, InsertEnter)
- **Command-based loading**: Plugins load when their commands are called
- **Key-based loading**: Plugins load when their keybindings are triggered
- **Filetype-based loading**: Language-specific plugins load only for relevant files

### Startup Time Analysis

To analyze Neovim startup time:

```vim
" Check startup time
:StartupTime

" Profile startup
nvim --startuptime startup.log
```

## Troubleshooting

### Common Issues and Solutions

1. **Language servers not installing**
   ```bash
   # Open Neovim and run
   :Mason
   # Press 'i' to install servers manually
   ```

2. **Treesitter parsers not installing**
   ```vim
   :TSInstall <language>
   # Or update all
   :TSUpdate
   ```

3. **Clipboard not working in WSL**
   ```bash
   # Ensure win32yank is in PATH
   which win32yank
   # Test clipboard
   echo "test" | win32yank.exe -i
   win32yank.exe -o
   ```

4. **Java LSP not starting**
   ```bash
   # Ensure JAVA_HOME is set
   echo $JAVA_HOME
   # Install JDK if missing
   sudo apt install openjdk-17-jdk  # Ubuntu
   brew install openjdk@17          # macOS
   ```

5. **Slow startup time**
   ```vim
   " Disable unused plugins in lazy.lua
   " Check startup time
   :Lazy profile
   ```

### Health Check

Run health check to diagnose issues:

```vim
:checkhealth
```

This will check:
- Neovim version and features
- Provider status (Python, Node.js, Ruby)
- Clipboard functionality
- Plugin status

## Maintenance

### Updating Neovim

#### Ubuntu/WSL
```bash
sudo apt update && sudo apt upgrade neovim
```

#### macOS
```bash
brew upgrade neovim
```

### Updating Plugins

```vim
" Update all plugins
:Lazy sync

" Update specific plugin
:Lazy update <plugin-name>

" Clean unused plugins
:Lazy clean
```

### Updating Language Servers

```vim
" Open Mason
:Mason

" Press 'U' to update all
" Or select specific servers and press 'u'
```

## Additional Resources

### Official Documentation
- [Neovim Documentation](https://neovim.io/doc/)
- [Neovim GitHub](https://github.com/neovim/neovim)
- [lazy.nvim Documentation](https://github.com/folke/lazy.nvim)

### Language Server Resources
- [nvim-lspconfig Server Configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- [Mason Registry](https://mason-registry.dev/)
- [TypeScript Language Server](https://github.com/typescript-language-server/typescript-language-server)
- [Eclipse JDT Language Server](https://github.com/eclipse/eclipse.jdt.ls)

### Learning Resources
- [Neovim from Scratch Series](https://github.com/LunarVim/Neovim-from-scratch)
- [ThePrimeagen's Neovim Config](https://github.com/ThePrimeagen/init.lua)
- [TJ DeVries' Neovim Config](https://github.com/tjdevries/config_manager)

### Plugin Collections
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)
- [Neovimcraft](https://neovimcraft.com/)
- [This Week in Neovim](https://this-week-in-neovim.org/)

## Best Practices

1. **Start Simple**: Begin with minimal configuration and add features gradually
2. **Use Version Control**: Keep your configuration in a git repository
3. **Document Custom Functions**: Add comments to complex configurations
4. **Regular Updates**: Keep Neovim, plugins, and language servers updated
5. **Profile Performance**: Monitor startup time and plugin performance
6. **Learn Vim Motions**: Master basic Vim movements before adding plugins
7. **Customize Gradually**: Adapt configuration to your specific workflow
8. **Backup Configuration**: Keep backups before major changes
9. **Use Stable Versions**: Prefer stable plugin versions for production work
10. **Read Plugin Documentation**: Understand what each plugin does before installing