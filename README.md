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
