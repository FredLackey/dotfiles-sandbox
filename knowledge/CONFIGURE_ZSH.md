# ZSH Configuration for Ubuntu Server and Ubuntu WSL

## Overview

ZSH (Z Shell) is a powerful, highly customizable shell that provides enhanced features over the default Bash shell. This document covers the installation and configuration process for both Ubuntu Server and Ubuntu WSL environments.

## Installation

### Prerequisites
- Ubuntu Server 22.04 LTS or Ubuntu on WSL
- Administrative (sudo) privileges
- Internet connection for package downloads

### Basic Installation Steps

1. **Update package lists**
   ```bash
   sudo apt update
   ```

2. **Install ZSH**
   ```bash
   sudo apt install zsh
   ```

3. **Verify installation**
   ```bash
   zsh --version
   ```
   Expected output: `zsh 5.8.1` or newer

4. **Set ZSH as default shell**
   ```bash
   chsh -s $(which zsh)
   ```
   Note: This change takes effect after logging out and back in.

## Configuration Files and Load Order

### ZSH Startup Files

ZSH loads configuration files in a specific order depending on the shell type (login/non-login, interactive/non-interactive):

#### System-wide Configuration Files (in /etc/)
1. `/etc/zshenv` - Always sourced first, for all ZSH instances
2. `/etc/zprofile` - Sourced for login shells
3. `/etc/zshrc` - Sourced for interactive shells
4. `/etc/zlogin` - Sourced for login shells (after zshrc)

#### User-specific Configuration Files (in ~/)
1. `~/.zshenv` - Environment variables (sourced for all shells)
2. `~/.zprofile` - Login shell configuration (before zshrc)
3. `~/.zshrc` - Interactive shell configuration (main config file)
4. `~/.zlogin` - Login shell configuration (after zshrc)
5. `~/.zlogout` - Cleanup tasks when exiting a login shell

### File Load Order by Shell Type

**Interactive Login Shell:**
1. `/etc/zshenv`
2. `~/.zshenv`
3. `/etc/zprofile`
4. `~/.zprofile`
5. `/etc/zshrc`
6. `~/.zshrc`
7. `/etc/zlogin`
8. `~/.zlogin`

**Interactive Non-Login Shell:**
1. `/etc/zshenv`
2. `~/.zshenv`
3. `/etc/zshrc`
4. `~/.zshrc`

**Non-Interactive Shell (scripts):**
1. `/etc/zshenv`
2. `~/.zshenv`

## Environment-Specific Considerations

### Ubuntu WSL Specifics

#### Default Shell Configuration
For WSL, you may need to configure Windows Terminal or your WSL shortcut to use ZSH:

1. **Modern WSL (WSL2):** The `chsh` command works normally
2. **Older WSL versions:** May require modifying the Windows shortcut or adding to `~/.bashrc`:
   ```bash
   if test -t 1; then
       exec zsh
   fi
   ```

#### Path Handling in WSL
WSL automatically includes Windows paths in the Linux PATH. This can be managed in `/etc/wsl.conf`:
```ini
[interop]
appendWindowsPath = false  # Disable if you don't want Windows paths
```

### Ubuntu Server Specifics

#### SSH Considerations
When connecting via SSH:
- Login shells are typically used, loading the full configuration chain
- Ensure `.zshrc` is sourced for interactive SSH sessions
- Non-interactive SSH commands (e.g., `ssh server 'command'`) only source `.zshenv`

#### Terminal Multiplexers
When using tmux or screen:
- New windows/panes typically spawn non-login interactive shells
- Only `.zshenv` and `.zshrc` are sourced for new panes

## Configuration Best Practices

### File Purpose Guidelines

#### ~/.zshenv
- Set environment variables needed by all shells
- Keep minimal - this is sourced even by scripts
- Example content:
  ```bash
  export EDITOR='vim'
  export LANG='en_US.UTF-8'
  ```

#### ~/.zprofile
- Set PATH and other login-specific configurations
- Run commands that should execute once per login
- Example content:
  ```bash
  # Add local bin to PATH
  export PATH="$HOME/.local/bin:$PATH"
  ```

#### ~/.zshrc
- Main configuration file for interactive use
- Aliases, functions, prompt configuration
- Plugin configurations (Oh My Zsh, etc.)
- Example content:
  ```bash
  # Aliases
  alias ll='ls -alF'
  alias la='ls -A'
  
  # History configuration
  HISTSIZE=10000
  SAVEHIST=10000
  HISTFILE=~/.zsh_history
  ```

### Important Notes

1. **Idempotency**: Ensure configurations can be sourced multiple times without issues
2. **Performance**: Keep `.zshenv` minimal as it's sourced for every shell
3. **PATH Management**: Be aware that `/etc/zprofile` may override PATH settings from `.zshenv`
4. **ZDOTDIR**: If set, ZSH looks for user config files in `$ZDOTDIR` instead of `$HOME`

## Oh My Zsh Installation (Optional)

Oh My Zsh is a popular framework for managing ZSH configuration:

### Installation
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Post-Installation
- Configuration file: `~/.zshrc`
- Themes directory: `~/.oh-my-zsh/themes/`
- Plugins directory: `~/.oh-my-zsh/plugins/`

### Theme Configuration
Edit `~/.zshrc` and set:
```bash
ZSH_THEME="robbyrussell"  # or "agnoster", "powerlevel10k/powerlevel10k", etc.
```

## Troubleshooting

### Common Issues

1. **chsh: command not found**
   - Install: `sudo apt install passwd`

2. **Shell not in /etc/shells**
   - Add ZSH to allowed shells: `echo $(which zsh) | sudo tee -a /etc/shells`

3. **Configuration not loading**
   - Check shell type: `echo $0` (should show `-zsh` for login shell)
   - Verify file permissions: `ls -la ~/.z*`

4. **PATH issues after login**
   - Check if `/etc/zprofile` is overriding your PATH
   - Set PATH in `~/.zprofile` instead of `~/.zshenv`

## References

- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
- [Oh My Zsh](https://ohmyz.sh/)
- [ZSH Users Guide](https://zsh.sourceforge.io/Guide/)
- [Arch Linux ZSH Wiki](https://wiki.archlinux.org/title/Zsh)