#!/usr/bin/env bash

# ZSH installation and configuration script for Ubuntu Server
# This script installs ZSH if needed and configures it as the default shell
# Designed to be idempotent - safe to run multiple times

set -e

# Source utilities if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$PARENT_DIR/../utils/output.sh" ]; then
    source "$PARENT_DIR/../utils/output.sh"
else
    # Fallback output functions
    print_success() { echo "   [✔] $1"; }
    print_error() { echo "   [✖] $1"; }
    print_info() { echo "   [i] $1"; }
    print_warning() { echo "   [!] $1"; }
    print_title() { echo -e "\n   $1\n"; }
    execute() {
        local CMDS="$1"
        local MSG="${2:-$1}"
        echo "   [⋯] $MSG"
        if eval "$CMDS" > /dev/null 2>&1; then
            echo -e "\033[1A\033[K   [✔] $MSG"
            return 0
        else
            echo -e "\033[1A\033[K   [✖] $MSG"
            return 1
        fi
    }
fi

# Check if command exists
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Install ZSH if not present
install_zsh() {
    print_title "Installing ZSH"
    
    if check_command zsh; then
        local current_version=$(zsh --version 2>/dev/null | awk '{print $2}')
        print_success "ZSH already installed (version $current_version)"
        
        # Update to latest version if available
        execute \
            "sudo apt-get update -qq && sudo apt-get install -qqy --only-upgrade zsh" \
            "Checking for ZSH updates"
    else
        # Update package lists first
        execute \
            "sudo apt-get update -qq" \
            "Updating package lists"
        
        # Install ZSH
        execute \
            "sudo apt-get install -qqy zsh" \
            "Installing ZSH"
        
        # Verify installation
        if check_command zsh; then
            local version=$(zsh --version 2>/dev/null | awk '{print $2}')
            print_success "ZSH installed successfully (version $version)"
        else
            print_error "Failed to install ZSH"
            return 1
        fi
    fi
}

# Ensure ZSH is in /etc/shells
add_zsh_to_shells() {
    print_title "Configuring allowed shells"
    
    local zsh_path=$(which zsh 2>/dev/null)
    
    if [ -z "$zsh_path" ]; then
        print_error "ZSH not found in PATH"
        return 1
    fi
    
    # Check if ZSH is already in /etc/shells
    if grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
        print_success "ZSH already in /etc/shells ($zsh_path)"
    else
        execute \
            "echo '$zsh_path' | sudo tee -a /etc/shells > /dev/null" \
            "Adding ZSH to /etc/shells"
    fi
}

# Set ZSH as default shell for current user
set_default_shell() {
    print_title "Setting default shell"
    
    local current_shell=$(echo $SHELL)
    local zsh_path=$(which zsh 2>/dev/null)
    
    if [ -z "$zsh_path" ]; then
        print_error "ZSH not found in PATH"
        return 1
    fi
    
    # Check if ZSH is already the default shell
    if [ "$current_shell" = "$zsh_path" ]; then
        print_success "ZSH is already the default shell"
    else
        # Check if chsh command exists
        if ! check_command chsh; then
            print_warning "chsh command not found, installing passwd package"
            execute \
                "sudo apt-get install -qqy passwd" \
                "Installing passwd package"
        fi
        
        # Change default shell
        if execute "sudo chsh -s '$zsh_path' '$USER'" "Setting ZSH as default shell for $USER"; then
            print_info "Shell change will take effect on next login"
        else
            print_warning "Failed to set default shell automatically"
            print_info "You can manually set it with: chsh -s $zsh_path"
        fi
    fi
}

# Create basic ZSH configuration files
create_zsh_config() {
    print_title "Creating ZSH configuration"
    
    # Create .zshenv for environment variables (always sourced)
    if [ ! -f "$HOME/.zshenv" ]; then
        cat > "$HOME/.zshenv" << 'EOF'
# ~/.zshenv - Environment variables for all ZSH shells
# This file is sourced for all shells (login, interactive, and scripts)

# Set default editor
export EDITOR='vim'

# Set language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Add user's private bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add user's bin to PATH if it exists
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi
EOF
        print_success "Created ~/.zshenv"
    else
        print_success "~/.zshenv already exists"
    fi
    
    # Create .zprofile for login shell configuration
    if [ ! -f "$HOME/.zprofile" ]; then
        cat > "$HOME/.zprofile" << 'EOF'
# ~/.zprofile - Login shell configuration
# This file is sourced for login shells only

# Nothing here yet - PATH is set in .zshenv to be available everywhere
EOF
        print_success "Created ~/.zprofile"
    else
        print_success "~/.zprofile already exists"
    fi
    
    # Create basic .zshrc for interactive shells
    if [ ! -f "$HOME/.zshrc" ]; then
        cat > "$HOME/.zshrc" << 'EOF'
# ~/.zshrc - Interactive shell configuration
# This file is sourced for interactive shells only

# Enable colors
autoload -U colors && colors

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS        # Don't record duplicate commands
setopt HIST_IGNORE_SPACE       # Don't record commands starting with space
setopt SHARE_HISTORY           # Share history between sessions
setopt EXTENDED_HISTORY        # Save timestamp and duration

# Basic auto-completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Case-insensitive completion

# Directory navigation
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD             # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates onto stack
setopt CDABLE_VARS            # Expand variables in cd

# Prompt configuration (simple and clean)
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Colored output for ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Key bindings
bindkey -e                     # Use emacs key bindings
bindkey '^[[A' history-search-backward  # Up arrow
bindkey '^[[B' history-search-forward   # Down arrow
bindkey '^[[H' beginning-of-line        # Home
bindkey '^[[F' end-of-line              # End
bindkey '^[[3~' delete-char             # Delete

# Load custom configurations if they exist
if [ -d "$HOME/.zshrc.d" ]; then
    for config in "$HOME/.zshrc.d"/*.zsh; do
        [ -r "$config" ] && source "$config"
    done
fi

# Source local configuration if it exists
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
EOF
        print_success "Created ~/.zshrc with basic configuration"
    else
        print_success "~/.zshrc already exists"
        print_info "Preserving existing configuration"
    fi
    
    # Create .zshrc.d directory for modular configurations
    if [ ! -d "$HOME/.zshrc.d" ]; then
        mkdir -p "$HOME/.zshrc.d"
        print_success "Created ~/.zshrc.d directory for modular configs"
    else
        print_success "~/.zshrc.d directory already exists"
    fi
}

# Handle special WSL configurations
configure_wsl_specific() {
    # Check if we're in WSL
    if [ ! -f /proc/version ] || ! grep -qi "microsoft\|wsl" /proc/version; then
        return 0  # Not WSL, nothing to do
    fi
    
    print_title "Applying WSL-specific configurations"
    
    # For older WSL versions, ensure ZSH starts from bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
            cat >> "$HOME/.bashrc" << 'EOF'

# Launch ZSH if in interactive terminal (WSL compatibility)
if test -t 1; then
    exec zsh
fi
EOF
            print_success "Added ZSH launcher to ~/.bashrc for WSL"
        else
            print_success "WSL ZSH launcher already in ~/.bashrc"
        fi
    fi
    
    # Add WSL-specific aliases if not already present
    local wsl_config="$HOME/.zshrc.d/wsl.zsh"
    if [ ! -f "$wsl_config" ]; then
        cat > "$wsl_config" << 'EOF'
# WSL-specific configurations and aliases

# Windows interop aliases
alias explorer='explorer.exe'
alias code='code.exe'
alias notepad='notepad.exe'

# Navigate to Windows home directory
alias winhome='cd /mnt/c/Users/$USER'

# Copy/paste integration with Windows clipboard
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'
EOF
        print_success "Created WSL-specific configuration"
    else
        print_success "WSL configuration already exists"
    fi
}

# Verify installation
verify_installation() {
    print_title "Verifying installation"
    
    local success=true
    
    # Check ZSH is installed
    if check_command zsh; then
        local version=$(zsh --version 2>/dev/null | awk '{print $2}')
        print_success "ZSH installed (version $version)"
    else
        print_error "ZSH not found"
        success=false
    fi
    
    # Check configuration files
    local config_files=(".zshenv" ".zprofile" ".zshrc")
    for file in "${config_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            print_success "$file exists"
        else
            print_warning "$file not found"
        fi
    done
    
    # Check if ZSH is in /etc/shells
    local zsh_path=$(which zsh 2>/dev/null)
    if [ -n "$zsh_path" ] && grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
        print_success "ZSH is in /etc/shells"
    else
        print_warning "ZSH not in /etc/shells"
    fi
    
    # Check default shell
    if [ "$SHELL" = "$zsh_path" ]; then
        print_success "ZSH is the default shell"
    else
        print_info "ZSH is not yet the default shell (requires re-login)"
    fi
    
    if [ "$success" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    print_title "ZSH Setup for Ubuntu Server"
    
    # Install ZSH
    install_zsh || {
        print_error "Failed to install ZSH"
        return 1
    }
    
    # Configure allowed shells
    add_zsh_to_shells || {
        print_warning "Failed to add ZSH to allowed shells"
        # Continue anyway as this is not critical
    }
    
    # Create configuration files
    create_zsh_config || {
        print_error "Failed to create configuration files"
        return 1
    }
    
    # Apply WSL-specific configurations if needed
    configure_wsl_specific
    
    # Set as default shell (do this after configs are created)
    set_default_shell || {
        print_warning "Failed to set default shell"
        # Continue anyway as user can do this manually
    }
    
    # Verify installation
    verify_installation
    
    print_title "ZSH Setup Complete"
    print_info "Log out and back in for shell change to take effect"
    print_info "Run 'zsh' to start using ZSH immediately"
    
    return 0
}

# Execute main function when script is run directly
main "$@"