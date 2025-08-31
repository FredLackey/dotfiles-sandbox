#!/usr/bin/env bash

# Bash Setup Script
# Configures Bash as fallback shell with enhanced features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PLATFORM="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

log_info() {
    echo -e "${BLUE}[BASH]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[BASH]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[BASH]${NC} $1"
}

log_error() {
    echo -e "${RED}[BASH]${NC} $1"
}

# Backup existing file
backup_file() {
    local file="$1"
    if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up $file to $backup"
        cp "$file" "$backup"
    fi
}

# Setup .bashrc
setup_bashrc() {
    local bashrc_path="$HOME/.bashrc"
    
    # Backup existing .bashrc
    backup_file "$bashrc_path"
    
    log_info "Creating enhanced .bashrc configuration..."
    
    cat > "$bashrc_path" << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History configuration
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Enhanced prompt with git support
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Set colorful prompt
if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '
else
    PS1='\u@\h:\w$(parse_git_branch)\$ '
fi

# Enable color support
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Load common configurations
if [[ -f "$HOME/.files/common/aliases.sh" ]]; then
    source "$HOME/.files/common/aliases.sh"
fi

if [[ -f "$HOME/.files/common/functions.sh" ]]; then
    source "$HOME/.files/common/functions.sh"
fi

if [[ -f "$HOME/.files/common/exports.sh" ]]; then
    source "$HOME/.files/common/exports.sh"
fi

# Load platform-specific configurations
case "$(uname -s)" in
    Darwin*)
        if [[ -f "$HOME/.files/platform/macos/bash.sh" ]]; then
            source "$HOME/.files/platform/macos/bash.sh"
        fi
        ;;
    Linux*)
        if [[ -f "$HOME/.files/platform/ubuntu/bash.sh" ]]; then
            source "$HOME/.files/platform/ubuntu/bash.sh"
        fi
        ;;
esac

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nano'

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
EOF
    
    log_success "Enhanced .bashrc created at $bashrc_path"
}

# Setup .bash_profile
setup_bash_profile() {
    local bash_profile_path="$HOME/.bash_profile"
    
    # Backup existing .bash_profile
    backup_file "$bash_profile_path"
    
    log_info "Creating .bash_profile..."
    
    cat > "$bash_profile_path" << 'EOF'
# ~/.bash_profile: executed by bash(1) for login shells.

# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH

# Load common exports
if [[ -f "$HOME/.files/common/exports.sh" ]]; then
    source "$HOME/.files/common/exports.sh"
fi

# Platform-specific login configurations
case "$(uname -s)" in
    Darwin*)
        # macOS specific login setup
        if [[ -f "$HOME/.files/platform/macos/profile.sh" ]]; then
            source "$HOME/.files/platform/macos/profile.sh"
        fi
        ;;
    Linux*)
        # Ubuntu/Linux specific login setup
        if [[ -f "$HOME/.files/platform/ubuntu/profile.sh" ]]; then
            source "$HOME/.files/platform/ubuntu/profile.sh"
        fi
        ;;
esac
EOF
    
    log_success ".bash_profile created at $bash_profile_path"
}

# Install bash-completion if needed
install_bash_completion() {
    case "$PLATFORM" in
        "ubuntu")
            if ! dpkg -l | grep -q bash-completion; then
                log_info "Installing bash-completion..."
                if command -v apt-get >/dev/null 2>&1; then
                    sudo apt-get update
                    sudo apt-get install -y bash-completion
                    log_success "bash-completion installed"
                else
                    log_warning "apt-get not available, skipping bash-completion installation"
                fi
            else
                log_info "bash-completion is already installed"
            fi
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                if ! brew list bash-completion &>/dev/null; then
                    log_info "Installing bash-completion via Homebrew..."
                    brew install bash-completion
                    log_success "bash-completion installed"
                else
                    log_info "bash-completion is already installed"
                fi
            else
                log_info "Homebrew not available, bash-completion may need manual installation"
            fi
            ;;
        *)
            log_info "Platform-specific bash-completion installation not configured for: $PLATFORM"
            ;;
    esac
}

# Main Bash setup function
main() {
    log_info "Setting up Bash configuration for platform: $PLATFORM"
    
    # Setup .bashrc
    setup_bashrc
    
    # Setup .bash_profile
    setup_bash_profile
    
    # Install bash-completion
    install_bash_completion
    
    log_success "Bash setup completed successfully!"
    log_info "Restart your terminal or run 'source ~/.bashrc' to apply changes"
}

# Run main function
main "$@"
