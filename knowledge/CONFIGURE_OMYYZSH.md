# Oh My Zsh Configuration for Ubuntu Server and Ubuntu WSL

## Overview

Oh My Zsh is a delightful, open-source, community-driven framework for managing your ZSH configuration. It comes bundled with thousands of helpful functions, helpers, plugins, themes, and features that enhance your terminal experience. This document provides comprehensive instructions for installing and configuring Oh My Zsh on Ubuntu Server and Ubuntu WSL environments.

## Prerequisites

- **ZSH already installed** (see CONFIGURE_ZSH.md for installation steps)
- **Git installed** for cloning the Oh My Zsh repository
- **curl or wget** for downloading the installation script
- **Internet connection** for downloading Oh My Zsh and plugins

## Installation

### Step 1: Verify Prerequisites

Before installing Oh My Zsh, ensure ZSH and Git are installed:

```bash
# Check ZSH installation
zsh --version
# Expected output: zsh 5.8.1 or newer

# Check Git installation
git --version
# If not installed:
sudo apt update
sudo apt install git
```

### Step 2: Install Oh My Zsh

You can install Oh My Zsh using either curl or wget:

**Using curl:**
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**Using wget:**
```bash
sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

The installer will:
1. Back up your existing `~/.zshrc` file (if it exists) to `~/.zshrc.pre-oh-my-zsh`
2. Clone the Oh My Zsh repository to `~/.oh-my-zsh`
3. Create a new `~/.zshrc` configuration file with Oh My Zsh template
4. Change your default shell to ZSH (if not already set)

## Directory Structure

After installation, Oh My Zsh creates the following directory structure:

```
~/.oh-my-zsh/
├── cache/          # Cached files for faster loading
├── custom/         # User customizations (plugins, themes, aliases)
│   ├── plugins/    # Custom plugins directory
│   ├── themes/     # Custom themes directory
│   └── example.zsh # Example custom configuration file
├── lib/            # Core library files
├── log/            # Update logs
├── plugins/        # Built-in plugins (300+)
├── templates/      # Configuration templates
├── themes/         # Built-in themes (150+)
└── tools/          # Utility scripts
```

## Configuration File (~/.zshrc)

The main configuration file `~/.zshrc` controls Oh My Zsh behavior. Key sections include:

### Basic Configuration Structure

```bash
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme configuration (see Themes section)
ZSH_THEME="robbyrussell"

# Plugin configuration (see Plugins section)
plugins=(git)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration (aliases, exports, etc.)
# Your custom configurations go here
```

## Themes

### Built-in Themes

Oh My Zsh includes 150+ built-in themes located in `~/.oh-my-zsh/themes/`. To change your theme:

1. Edit `~/.zshrc`:
   ```bash
   nano ~/.zshrc
   ```

2. Find and modify the `ZSH_THEME` line:
   ```bash
   # Popular theme choices:
   ZSH_THEME="robbyrussell"  # Default, simple and clean
   ZSH_THEME="agnoster"       # Powerline-style, requires special fonts
   ZSH_THEME="powerlevel10k/powerlevel10k"  # Highly customizable
   ZSH_THEME="arrow"          # Minimal with arrow prompt
   ZSH_THEME="cloud"          # Cloud-themed prompt
   ```

3. Apply changes:
   ```bash
   source ~/.zshrc
   ```

### Powerline Fonts for Advanced Themes

Some themes (like agnoster) require Powerline fonts for proper display:

#### Ubuntu/WSL Installation:
```bash
# Install fonts package
sudo apt-get install fonts-powerline

# Alternative: Clone and install manually
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
```

#### WSL-Specific Configuration:
For WSL, you also need to install Powerline fonts on Windows:
1. Clone the repository on Windows: `git clone https://github.com/powerline/fonts.git`
2. Run PowerShell as Administrator
3. Navigate to the fonts directory
4. Execute: `.\install.ps1`
5. Configure your terminal (Windows Terminal, ConEmu, etc.) to use a Powerline font

## Plugins

### Enabling Built-in Plugins

Oh My Zsh comes with 300+ built-in plugins. To enable them:

1. Edit `~/.zshrc`:
   ```bash
   nano ~/.zshrc
   ```

2. Add plugins to the plugins array:
   ```bash
   # Essential plugins for developers
   plugins=(
     git                # Git aliases and functions
     ubuntu             # Ubuntu-specific aliases
     docker             # Docker completions and aliases
     docker-compose     # Docker Compose completions
     npm                # npm completions and aliases
     node               # Node.js completions
     python             # Python completions
     sudo               # Press ESC twice to add sudo to command
     command-not-found  # Suggests packages for unknown commands
     history            # History management shortcuts
     z                  # Directory jumping
   )
   ```

3. Apply changes:
   ```bash
   source ~/.zshrc
   ```

### Installing Third-Party Plugins

Popular third-party plugins from the zsh-users community:

#### Method 1: Manual Installation

1. Navigate to custom plugins directory:
   ```bash
   cd ~/.oh-my-zsh/custom/plugins
   ```

2. Clone desired plugins:
   ```bash
   # Auto-suggestions (fish-like)
   git clone https://github.com/zsh-users/zsh-autosuggestions

   # Syntax highlighting
   git clone https://github.com/zsh-users/zsh-syntax-highlighting

   # Additional completions
   git clone https://github.com/zsh-users/zsh-completions
   ```

3. Add to plugins array in `~/.zshrc`:
   ```bash
   plugins=(
     # ... other plugins
     zsh-autosuggestions
     zsh-syntax-highlighting
     zsh-completions
   )
   ```

4. For zsh-completions, add before `source $ZSH/oh-my-zsh.sh`:
   ```bash
   fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
   ```

#### Method 2: Using Plugin Managers

For advanced plugin management, consider using:
- **Antigen**: `apt-get install zsh-antigen`
- **zplug**: More modern plugin manager
- **zinit**: Fast and feature-rich plugin manager

## WSL-Specific Configurations

### Terminal Integration

#### Configure .bashrc for Automatic ZSH Launch
For older WSL versions or if chsh doesn't work properly:

```bash
# Add to ~/.bashrc
if test -t 1; then
    exec zsh
fi
```

#### Windows Terminal Configuration
In Windows Terminal settings.json:
```json
{
    "profiles": {
        "list": [
            {
                "guid": "{your-wsl-guid}",
                "name": "Ubuntu (ZSH)",
                "commandline": "wsl.exe ~",
                "fontFace": "MesloLGS NF",  // Powerline font
                "fontSize": 11
            }
        ]
    }
}
```

### Directory Colors Fix

WSL may have poor default directory colors. To fix:

1. Install Solarized dircolors:
   ```bash
   curl https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark --output ~/.dircolors
   ```

2. Add to `~/.zshrc`:
   ```bash
   # Set LS_COLORS for better visibility
   eval `dircolors ~/.dircolors`
   ```

## Ubuntu Server Specific Configurations

### SSH Session Handling

For SSH connections to Ubuntu Server, ensure Oh My Zsh loads properly:

1. Verify `~/.zshrc` is sourced for SSH sessions
2. For non-interactive SSH commands, minimal configuration in `~/.zshenv`:
   ```bash
   # Only essential exports for non-interactive sessions
   export PATH="$HOME/.local/bin:$PATH"
   ```

### Tmux Integration

For terminal multiplexer compatibility, add to `~/.zshrc`:
```bash
# Tmux plugin for Oh My Zsh
plugins=(... tmux)

# Tmux configuration
export ZSH_TMUX_AUTOSTART=false  # Set to true for auto-start
export ZSH_TMUX_AUTOCONNECT=false  # Set to true for auto-connect
```

## Custom Aliases and Functions

### Creating Custom Configuration Files

Place custom configurations in `~/.oh-my-zsh/custom/`:

1. Create a custom file:
   ```bash
   nano ~/.oh-my-zsh/custom/my-aliases.zsh
   ```

2. Add your aliases:
   ```bash
   # System aliases
   alias ll='ls -alF'
   alias la='ls -A'
   alias l='ls -CF'
   
   # Git aliases (additional to plugin)
   alias gst='git status'
   alias gco='git checkout'
   alias gcm='git commit -m'
   
   # Docker aliases
   alias dps='docker ps'
   alias dimg='docker images'
   
   # Navigation
   alias ..='cd ..'
   alias ...='cd ../..'
   alias ....='cd ../../..'
   ```

3. Files in `custom/` are automatically loaded

## Auto-Update Configuration

Configure Oh My Zsh auto-updates in `~/.zshrc`:

```bash
# Disable automatic updates
zstyle ':omz:update' mode disabled

# Auto-update without prompting
zstyle ':omz:update' mode auto

# Just remind me to update
zstyle ':omz:update' mode reminder

# Update frequency (in days)
zstyle ':omz:update' frequency 13
```

Manual update command:
```bash
omz update
```

## Performance Optimization

### Disable Unused Plugins

Only enable plugins you actively use to improve startup time:
```bash
# Instead of:
plugins=(git docker kubectl terraform aws gcloud npm node python ruby rails postgres mysql)

# Use only what you need:
plugins=(git docker npm node)
```

### Lazy Loading

For heavy plugins, consider lazy loading:
```bash
# In ~/.zshrc or custom file
# Lazy load nvm
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
```

### Compilation Cache

Oh My Zsh automatically compiles scripts for faster loading. Clear cache if experiencing issues:
```bash
rm -rf ~/.oh-my-zsh/cache/*
rm -f ~/.zcompdump*
```

## Troubleshooting

### Common Issues and Solutions

1. **Broken characters/fonts in theme**
   - Install Powerline fonts (see Themes section)
   - Configure terminal to use Powerline font
   - Try a simpler theme like "robbyrussell"

2. **Slow startup time**
   - Reduce number of plugins
   - Clear cache: `rm -rf ~/.oh-my-zsh/cache/*`
   - Profile startup: `zsh -xv 2>&1 | ts -i "%.s" > zsh_startup.log`

3. **Plugin not working**
   - Verify plugin exists: `ls ~/.oh-my-zsh/plugins/` or `ls ~/.oh-my-zsh/custom/plugins/`
   - Check plugin name spelling in `~/.zshrc`
   - Run `source ~/.zshrc` after changes

4. **Auto-suggestions not visible**
   - Check terminal color support: `echo $TERM`
   - Adjust suggestion color: `export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'`

5. **Git plugin aliases conflict**
   - Check existing aliases: `alias | grep git`
   - Override in custom file after plugin loads

## Uninstallation

If you need to uninstall Oh My Zsh:

```bash
# Run the uninstaller
uninstall_oh_my_zsh

# Or manually:
rm -rf ~/.oh-my-zsh
mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc  # Restore original config
source ~/.zshrc
```

## Additional Resources

### Official Documentation
- [Oh My Zsh Website](https://ohmyz.sh/)
- [Oh My Zsh GitHub](https://github.com/ohmyzsh/ohmyzsh)
- [Oh My Zsh Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)

### Plugin Resources
- [Built-in Plugins List](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins)
- [Plugin Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)
- [zsh-users plugins](https://github.com/zsh-users)

### Theme Resources
- [Theme Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- [Theme Screenshots](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- [External Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/External-themes)

### Community
- [Oh My Zsh Discord](https://discord.gg/bpXWhnN)
- [Stack Overflow Tag](https://stackoverflow.com/questions/tagged/oh-my-zsh)

## Best Practices

1. **Keep it Simple**: Start with minimal configuration and add features as needed
2. **Regular Updates**: Keep Oh My Zsh updated for latest features and security fixes
3. **Backup Configuration**: Keep a backup of your `~/.zshrc` and custom files
4. **Document Customizations**: Comment your custom configurations for future reference
5. **Test Changes**: Always `source ~/.zshrc` after changes to verify they work
6. **Use Version Control**: Consider tracking your dotfiles in a git repository