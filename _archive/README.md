# Dotfiles Sandbox

A cross-platform dotfiles configuration system for Ubuntu and macOS, designed to provide a consistent development environment with ZSH as the primary shell and Bash as a fallback option.

## Purpose

This repository provides a comprehensive dotfiles setup that:

- **Cross-Platform Support**: Works seamlessly on both Ubuntu and macOS
- **Shell Flexibility**: Prioritizes ZSH but gracefully falls back to Bash when ZSH is not available or permitted
- **Modular Design**: Organized structure with separate configurations for each shell while sharing common utilities
- **Fully Automated**: Runs completely unattended with no user prompts required
- **Idempotent Installation**: Each setup step verifies existing configurations before making changes
- **User-Friendly**: Simple installation process with clear documentation

## Installation

### Prerequisites

- Git installed on your system
- Internet connection for downloading dependencies

### Quick Start

1. **Clone to your home directory**:
   ```bash
   cd ~
   git clone <repository-url> .files
   cd .files
   ```

2. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

The setup script will automatically:
- Detect your operating system (Ubuntu/macOS)
- Install ZSH if not available (falls back to Bash if installation fails)
- Configure your shell environment with enhanced features
- Set up dotfiles and configurations
- Install essential development tools and packages
- Apply platform-specific optimizations
- **Configure terminal themes** (Darcula-style dark theme for Terminal.app and iTerm2)

## Directory Structure

```
.files/
├── README.md              # This file
├── setup.sh              # Main installation script
├── zsh/                  # ZSH-specific configurations
│   ├── setup.sh          # ZSH setup script
│   ├── .zshrc            # ZSH configuration
│   └── plugins/          # ZSH plugins and themes
├── bash/                 # Bash-specific configurations
│   ├── setup.sh          # Bash setup script
│   ├── .bashrc           # Bash configuration
│   └── .bash_profile     # Bash profile
├── common/               # Shared configurations and utilities
│   ├── aliases.sh        # Common aliases
│   ├── functions.sh      # Shared functions
│   ├── exports.sh        # Environment variables
│   └── git/              # Git configurations
└── platform/             # Platform-specific configurations
    ├── ubuntu/           # Ubuntu-specific settings
    └── macos/            # macOS-specific settings
```

## Features

### Shell Management
- **Primary**: ZSH with oh-my-zsh framework
- **Fallback**: Bash with enhanced configuration
- **Smart Detection**: Automatically detects available shells

### Cross-Platform Compatibility
- **Ubuntu**: Optimized for Ubuntu environments
- **macOS**: Native macOS integration with Homebrew support
- **Shared**: Common configurations work across both platforms

### Modular Configuration
- **Separated Concerns**: Shell-specific vs shared configurations
- **Easy Maintenance**: Clear organization for updates and customization
- **Extensible**: Simple to add new tools and configurations

## Installed Tools and Applications

This dotfiles setup automatically installs and configures a comprehensive set of development tools and applications:

### macOS Tools (via Homebrew)

#### Essential Command-Line Tools
- **git** - Distributed version control system
- **curl** - Tool for transferring data with URLs
- **wget** - Network downloader for retrieving files
- **tree** - Display directories as trees with optional color/HTML output
- **htop** - Interactive process viewer and system monitor
- **jq** - Lightweight and flexible command-line JSON processor
- **ripgrep** - Line-oriented search tool that recursively searches directories for regex patterns
- **fd** - Simple, fast and user-friendly alternative to 'find'
- **bat** - Cat clone with syntax highlighting and Git integration
- **eza** - Modern replacement for ls with colors and icons
- **fzf** - Command-line fuzzy finder for interactive filtering
- **gnu-sed** - GNU version of sed for consistent text processing
- **gnu-tar** - GNU version of tar archival tool
- **coreutils** - GNU core utilities for file, shell and text manipulation
- **findutils** - GNU find utilities for searching files and directories
- **grep** - GNU grep for pattern searching in text

#### Development Tools and Languages
- **node** - JavaScript runtime built on Chrome's V8 engine
- **python@3.11** - Python 3.11 programming language interpreter
- **go** - Go programming language compiler and tools
- **rust** - Rust programming language and Cargo package manager
- **docker** - Platform for developing, shipping, and running applications in containers
- **docker-compose** - Tool for defining and running multi-container Docker applications
- **git-lfs** - Git extension for versioning large files
- **gh** - GitHub command line interface
- **vim** - Highly configurable text editor
- **neovim** - Hyperextensible Vim-based text editor

#### GUI Applications (via Homebrew Cask)
- **visual-studio-code** - Powerful source code editor with extensive extension support
- **google-chrome** - Google's web browser
- **firefox** - Mozilla's web browser
- **iterm2** - Enhanced terminal emulator for macOS
- **rectangle** - Window management utility for organizing app windows
- **the-unarchiver** - Archive utility for extracting various compressed file formats
- **vlc** - Versatile media player for various audio and video formats

### Ubuntu Tools (via APT)

#### Essential System Packages
- **curl** - Tool for transferring data with URLs
- **wget** - Network downloader for retrieving files
- **git** - Distributed version control system
- **vim** - Vi improved text editor
- **nano** - Simple, easy-to-use text editor
- **htop** - Interactive process viewer and system monitor
- **tree** - Display directories as trees
- **unzip** - Utility for extracting ZIP archives
- **zip** - Utility for creating ZIP archives
- **build-essential** - Essential compilation tools including gcc, make, and libraries
- **software-properties-common** - Tools for managing software repositories
- **apt-transport-https** - HTTPS transport method for APT
- **ca-certificates** - Common CA certificates for SSL/TLS verification
- **gnupg** - GNU Privacy Guard for encryption and signing
- **lsb-release** - Linux Standard Base version reporting utility
- **bash-completion** - Programmable completion functions for bash
- **command-not-found** - Suggests packages when commands are not found
- **xclip** - Command line interface to X11 clipboard
- **neovim** - Hyperextensible Vim-based text editor

#### Development Tools
- **nodejs** - JavaScript runtime and package manager
- **python3-pip** - Package installer for Python 3
- **python3-venv** - Virtual environment support for Python 3
- **python3-dev** - Development headers and libraries for Python 3
- **docker** - Container platform for application deployment

### Shell Enhancement Tools

#### ZSH Framework and Plugins
- **oh-my-zsh** - Framework for managing ZSH configuration with themes and plugins
- **zsh-autosuggestions** - Fish-like autosuggestions for ZSH based on command history
- **zsh-syntax-highlighting** - Real-time syntax highlighting for ZSH commands
- **powerlevel10k** - Fast and highly customizable ZSH theme with Git integration

#### Bash Enhancements
- **bash-completion** - Programmable completion system for bash commands and arguments

### Cross-Platform Configurations

#### Git Configuration
- **Global gitignore** - Comprehensive ignore patterns for common files and directories
- **Git aliases** - Shortcuts for common Git commands (st, co, br, ci, etc.)
- **Enhanced Git settings** - Improved defaults for core behavior, colors, and workflow

#### Shell Aliases and Functions
- **Navigation shortcuts** - Quick directory traversal (.., ..., cd -, etc.)
- **File operations** - Enhanced ls, cp, mv with safety flags and colors
- **Process management** - Improved ps, top, and process filtering commands
- **Development shortcuts** - Git, Docker, NPM, and Python workflow aliases
- **System information** - Quick access to system stats, network info, and hardware details
- **Text processing** - URL encoding/decoding, case conversion, and search functions

#### Environment Enhancements
- **Darcula-inspired color schemes** - Dark theme colors for terminal, ls, grep, and other tools
- **Performance optimizations** - Parallel make jobs, efficient history settings
- **Developer-friendly defaults** - UTF-8 locale, enhanced PATH, and tool-specific configurations

## Usage

After installation, your shell environment will be configured with:

- Enhanced prompt with git integration
- Useful aliases and functions
- Development tools and utilities
- Consistent behavior across platforms

### Customization

To customize your setup:

1. Edit files in the appropriate directory (`zsh/`, `bash/`, or `common/`)
2. Re-run the setup script: `~/.files/setup.sh`
3. Or source your shell configuration: `source ~/.zshrc` or `source ~/.bashrc`

## Development

This project follows these principles:

- **Idempotent**: Scripts can be run multiple times safely
- **Non-destructive**: Existing configurations are backed up
- **Modular**: Easy to enable/disable specific features
- **Well-documented**: Clear comments and documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both Ubuntu and macOS if possible
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Troubleshooting

### Common Issues

**ZSH not installing**: Check if you have sudo privileges and internet connectivity.

**Configurations not loading**: Ensure the setup script completed successfully and restart your terminal.

**Platform-specific issues**: Check the `platform/` directory for OS-specific configurations.

For more help, please open an issue in the repository.
