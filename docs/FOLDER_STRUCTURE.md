# Folder Structure

## Overview

This document outlines the organizational structure for our dotfiles repository, designed for clarity, maintainability, and platform independence across our three target environments: Windows WSL Ubuntu, Ubuntu Server 22.04 LTS, and macOS 15 (Sequoia).

## Design Principles

1. **Clear separation of concerns** - Each folder has a single, well-defined purpose
2. **Platform independence** - Platform-specific implementations are clearly isolated
3. **Logical grouping** - Related functionality is grouped together
4. **Flat where possible** - Avoid deep nesting unless it adds clarity
5. **Self-documenting structure** - Folder names clearly indicate their contents
6. **Shell version compatibility** - Account for different shell versions across platforms

## Proposed Structure

    dotfiles/
    ├── docs/                      # Documentation
    │   ├── FOLDER_STRUCTURE.md    # This document
    │   ├── INSTALLATION.md        # Installation guide
    │   └── DEVELOPMENT.md         # Development guidelines
    │
    ├── scripts/                   # Repository maintenance utilities
    │   ├── git/                   # Git workflow automation
    │   ├── docs/                  # Documentation generation
    │   └── validate/              # Code quality checks
    │
    ├── src/                       # Main source code
    │   ├── setup.sh               # Universal entry point - detects OS and runs appropriate setup
    │   ├── utils/                 # Helper scripts for main setup
    │   │   ├── detect_os.sh       # OS detection logic
    │   │   ├── verify_env.sh      # Environment verification
    │   │   └── common.sh          # Common functions for setup
    │   │
    │   ├── common/                # Cross-platform configurations
    │   │   ├── zsh/               # ZSH interactive shell configurations
    │   │   │   ├── aliases.zsh    # Universal ZSH aliases
    │   │   │   ├── exports.zsh    # ZSH environment variables
    │   │   │   ├── functions.zsh  # ZSH utility functions
    │   │   │   ├── prompt.zsh     # ZSH prompt configuration
    │   │   │   └── zshrc          # Main ZSH configuration file
    │   │   │
    │   │   ├── bash/              # Bash script utilities (not interactive)
    │   │   │   ├── aliases.sh     # Universal bash aliases (if needed)
    │   │   │   ├── exports.sh     # Bash environment variables for scripts
    │   │   │   ├── functions.sh   # Shared bash functions for scripts
    │   │   │   ├── prompt.sh      # Bash prompt (if ever needed)
    │   │   │   └── bashrc         # Main bash configuration (if needed)
    │   │   │
    │   │   └── config/            # Application configs (truly cross-platform)
    │   │       ├── git/           # Git configuration files
    │   │       ├── vim/           # Vim configuration files
    │   │       └── tmux/          # Tmux configuration files
    │   │
    │   ├── macos/                 # macOS-specific implementations
    │   │   ├── setup.sh           # Main macOS setup orchestrator
    │   │   ├── utils/             # Helper scripts for macOS setup
    │   │   │   ├── check_xcode.sh # Verify Xcode CLI tools
    │   │   │   ├── backup.sh      # Backup existing configs
    │   │   │   └── common.sh      # Common macOS functions
    │   │   │
    │   │   ├── packages/          # Package installations
    │   │   │   ├── homebrew.sh    # Homebrew setup and packages
    │   │   │   ├── apps.sh        # macOS applications via brew cask
    │   │   │   ├── cli_tools.sh   # Command-line tools
    │   │   │   └── utils/         # Package installation helpers
    │   │   │       ├── brew_helpers.sh  # Homebrew utility functions
    │   │   │       └── verify_install.sh # Verify installations
    │   │   │
    │   │   ├── preferences/       # System preferences
    │   │   │   ├── defaults.sh    # macOS defaults settings
    │   │   │   ├── dock.sh        # Dock configuration
    │   │   │   ├── finder.sh      # Finder preferences
    │   │   │   ├── terminal.sh    # Terminal.app settings
    │   │   │   └── utils/         # Preference setting helpers
    │   │   │       └── plist_helpers.sh # Property list utilities
    │   │   │
    │   │   ├── zsh/               # macOS-specific ZSH configs
    │   │   │   ├── aliases.zsh    # macOS-only ZSH aliases
    │   │   │   ├── exports.zsh    # macOS-only ZSH exports
    │   │   │   ├── functions.zsh  # macOS-only ZSH functions
    │   │   │   └── zshrc.macos    # macOS-specific ZSH settings
    │   │   │
    │   │   └── config/            # macOS-specific app configs
    │   │       └── terminal/      # Terminal.app configuration
    │   │
    │   ├── ubuntu/                # Ubuntu Server 22.04 LTS implementations
    │   │   ├── setup.sh           # Main Ubuntu setup orchestrator
    │   │   ├── utils/             # Helper scripts for Ubuntu setup
    │   │   │   ├── check_version.sh # Verify Ubuntu version
    │   │   │   ├── backup.sh      # Backup existing configs
    │   │   │   └── common.sh      # Common Ubuntu functions
    │   │   │
    │   │   ├── packages/          # Package installations
    │   │   │   ├── apt.sh         # APT package management
    │   │   │   ├── snap.sh        # Snap packages
    │   │   │   ├── cli_tools.sh   # Command-line tools
    │   │   │   └── utils/         # Package installation helpers
    │   │   │       ├── apt_helpers.sh   # APT utility functions
    │   │   │       └── verify_install.sh # Verify installations
    │   │   │
    │   │   ├── preferences/       # System preferences
    │   │   │   ├── system.sh      # System-level settings
    │   │   │   ├── console.sh     # Console/TTY settings
    │   │   │   └── utils/         # Preference setting helpers
    │   │   │       └── config_helpers.sh # Configuration utilities
    │   │   │
    │   │   ├── zsh/               # Ubuntu-specific ZSH configs
    │   │   │   ├── aliases.zsh    # Ubuntu-only ZSH aliases
    │   │   │   ├── exports.zsh    # Ubuntu-only ZSH exports
    │   │   │   ├── functions.zsh  # Ubuntu-only ZSH functions
    │   │   │   └── zshrc.ubuntu   # Ubuntu-specific ZSH settings
    │   │   │
    │   │   └── config/            # Ubuntu-specific app configs
    │   │       └── .gitkeep       # (Ubuntu Server has no GUI terminal)
    │   │
    │   └── wsl/                   # Windows WSL Ubuntu implementations
    │       ├── setup.sh           # Main WSL Ubuntu setup orchestrator
    │       ├── utils/             # Helper scripts for WSL setup
    │       │   ├── check_wsl.sh   # Verify WSL version and features
    │       │   ├── windows_paths.sh # Windows path integration
    │       │   └── common.sh      # Common WSL functions
    │       │
    │       ├── packages/          # Package installations
    │       │   ├── apt.sh         # APT package management
    │       │   ├── snap.sh        # Snap packages (if supported in WSL)
    │       │   ├── cli_tools.sh   # Command-line tools
    │       │   └── utils/         # Package installation helpers
    │       │       ├── apt_helpers.sh   # APT utility functions
    │       │       └── verify_install.sh # Verify installations
    │       │
    │       ├── preferences/       # WSL-specific preferences
    │       │   ├── wsl.conf       # WSL configuration file
    │       │   ├── interop.sh     # Windows interoperability settings
    │       │   ├── terminal.sh    # Terminal preferences
    │       │   └── utils/         # Preference setting helpers
    │       │       └── wsl_config_helpers.sh # WSL configuration utilities
    │       │
    │       ├── zsh/               # WSL-specific ZSH configs
    │       │   ├── aliases.zsh    # WSL-specific ZSH aliases (may include Windows paths)
    │       │   ├── exports.zsh    # WSL-specific ZSH exports
    │       │   ├── functions.zsh  # WSL-specific ZSH functions
    │       │   └── zshrc.wsl      # WSL-specific ZSH settings
    │       │
    │       └── config/            # WSL-specific app configs
    │           └── windows_terminal/  # Windows Terminal integration
    │
    ├── tests/                     # Test scripts (future)
    │
    └── _reference/                # Reference materials (not deployed)
        ├── _examples/             # Other developers' dotfiles
        ├── _legacy/               # Current production dotfiles
        └── _archive/              # Previous attempts (do not trust)

## Key Differences from _examples/alrra

### What We're Changing

1. **Eliminated unnecessary nesting**
   - alrra: `src/os/installs/` and `src/os/preferences/`
   - Ours: Direct `packages/` and `preferences/` under platform folders

2. **Better separation of configs vs scripts**
   - alrra: Mixed configuration files with installation scripts
   - Ours: Clear separation between `config/` (files) and scripts

3. **Platform-specific shell configurations**
   - alrra: Shell configs at root level with platform checks
   - Ours: Separate `shell/` folders per platform for OS-specific settings

4. **Clearer common vs platform-specific**
   - alrra: Not always clear what's universal
   - Ours: `common/` only contains truly cross-platform items

### What We're Keeping

1. **Platform folders** (macos/, ubuntu/) for OS-specific implementations
2. **Separation of packages and preferences**
3. **Modular script design** with focused, single-purpose files

## Folder Descriptions

### Utils Folder Pattern
Throughout the repository, `utils/` folders contain helper scripts and shared functions:
- **Located alongside executable scripts** - Every folder with main scripts has a utils subfolder
- **Shared functionality** - Common functions used by scripts in that directory
- **Modular helpers** - Small, focused utility scripts for specific tasks
- **Sourced by main scripts** - Main scripts source utils files for shared functionality
- **Idempotent utilities** - All util functions must be idempotent
- **Naming convention**: Use descriptive names ending in `.sh` for bash utilities

Examples:
- `/src/utils/` - Helpers for main setup.sh (OS detection, environment verification)
- `/src/macos/utils/` - macOS-specific helpers (Xcode checks, macOS common functions)
- `/src/*/packages/utils/` - Package installation helpers (verification, dependency checks)
- `/src/*/preferences/utils/` - Preference setting helpers (config file manipulation)

### `/src/setup.sh`
Universal entry point script that:
- Detects the current operating system and environment
- Determines if running on macOS, Ubuntu Server, or WSL
- Invokes the appropriate platform-specific setup script
- Provides clear error messages if running on unsupported platforms
- **This is the only script that uses platform detection**
- All other scripts assume they're running on their target platform

Example usage:
    
    # From any target environment:
    cd ~/dotfiles/src
    ./setup.sh
    
The script will automatically detect:
- macOS: Checks for Darwin kernel
- WSL: Checks for Microsoft or WSL in `/proc/version`
- Ubuntu Server: Checks for Ubuntu without WSL markers

### `/src/common/`
Only truly universal configurations that work identically across all three target platforms:
- **`zsh/`**: Universal ZSH interactive shell configurations
  - Each folder contains: aliases.zsh, exports.zsh, functions.zsh, prompt.zsh, zshrc
- **`bash/`**: Bash configurations (primarily for script utilities)
  - Each folder contains: aliases.sh, exports.sh, functions.sh, prompt.sh, bashrc
- **`config/`**: Application configs for cross-platform tools (git, vim, tmux)
- No OS-specific commands or paths
- **Important**: Must work with the lowest common denominator of shell versions
- **Consistency**: All shell folders follow the same file structure

### `/src/macos/`
macOS 15 (Sequoia) specific implementations:
- Homebrew package management
- macOS system preferences and defaults
- Terminal.app configurations (built-in terminal)
- macOS-specific shell enhancements

### `/src/ubuntu/`
Ubuntu Server 22.04 LTS specific implementations:
- APT package management
- Server-oriented configurations
- Console/TTY settings (no GUI by default)
- Ubuntu-specific shell enhancements

### `/src/wsl/`
Windows WSL Ubuntu specific implementations:
- WSL configuration (wsl.conf)
- Windows filesystem integration
- Windows Terminal integration
- Interoperability with Windows tools
- Path handling for both Linux and Windows filesystems

### `/src/[platform]/packages/`
Platform-specific package installation scripts:
- Package manager setup (Homebrew, APT, etc.)
- Application installations
- Development tool installations
- Each script is idempotent and self-contained

### `/src/[platform]/preferences/`
System preference modifications:
- OS-specific settings (defaults, dconf, etc.)
- Desktop environment configurations
- System behavior modifications

### `/src/[platform]/zsh/`
Platform-specific ZSH interactive shell enhancements:
- ZSH aliases that use OS-specific commands
- ZSH environment variables with platform paths
- ZSH functions that rely on platform utilities
- Platform-specific ZSH configurations
- **File naming**: Use `.zsh` extension for all ZSH config files
- **Shell version handling**: Each platform folder handles its own ZSH version differences
- **Version detection**: Scripts check ZSH version and adapt behavior as needed

### `/src/[platform]/config/`
Platform-specific application configuration files:
- Terminal configurations where applicable:
  - **macOS**: Terminal.app settings
  - **Ubuntu Server**: Console/TTY settings (no GUI terminal)
  - **WSL**: Windows Terminal integration (from Windows side)
- Platform-specific tool configurations
- **No third-party software** - only configure what ships with the OS

## Migration Notes

When adapting code from _examples/alrra:
1. Separate configuration files from installation scripts
2. Move platform-specific shell configs to platform folders
3. Ensure each script has a self-contained main() function
4. Remove cross-platform conditionals in favor of separate implementations
5. Group related functionality more logically

## Shell Version Strategy

### Philosophy
- **Never install or upgrade shells** - Use what ships with the OS
- **Platform folders handle version differences** - Each OS deals with its own shell quirks
- **No version detection in common/** - Common files use only universally supported features

### Version Considerations by Platform

#### macOS 15 (Sequoia)
- Ships with zsh 5.9
- Bash 3.2 (ancient, due to GPL licensing)
- Scripts in `src/macos/` written for these specific versions

#### Ubuntu Server 22.04 LTS
- zsh 5.8
- bash 5.1
- Scripts in `src/ubuntu/` written for these specific versions

#### Windows WSL Ubuntu
- Depends on the Ubuntu distribution installed (typically matches Ubuntu Server versions)
- May have additional considerations for Windows interoperability
- Scripts in `src/wsl/` handle WSL-specific requirements

### Implementation Approach
1. **Common folder**: Use POSIX-compliant syntax that works everywhere
2. **Platform folders**: Use version-specific features freely
3. **Version checks**: Done at platform level, not in common code
4. **Feature detection**: Prefer checking for command existence over version numbers

### Example Version Handling

    # In src/macos/zsh/functions.zsh
    # Can use macOS zsh 5.9 specific features freely
    
    # In src/ubuntu/zsh/functions.zsh  
    # Can use Ubuntu 22.04 LTS zsh 5.8 features
    
    # In src/wsl/zsh/functions.zsh
    # Handle WSL-specific features and Windows interop
    # May need to check for WSL version or Windows paths
    
    # In src/common/zsh/functions.zsh
    # Only use ZSH features that work in ALL three environments
    
    # In src/*/packages/homebrew.sh (bash script)
    # Written in bash for automation, not ZSH

## Benefits of This Structure

1. **Clarity**: Immediately clear where to find specific functionality
2. **Maintainability**: Easy to update platform-specific code without affecting others
3. **Testability**: Each script can be tested in isolation
4. **Scalability**: Easy to add new platforms (WSL, Windows) with their own folders
5. **Discoverability**: Logical organization helps new contributors understand the codebase
6. **Version flexibility**: Each platform handles its own shell version quirks independently