#!/usr/bin/env bash

# ZSH Setup Script
# Configures ZSH with oh-my-zsh and custom settings

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
    echo -e "${BLUE}[ZSH]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ZSH]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[ZSH]${NC} $1"
}

log_error() {
    echo -e "${RED}[ZSH]${NC} $1"
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

# Install oh-my-zsh if not already installed
install_oh_my_zsh() {
    local oh_my_zsh_dir="$HOME/.oh-my-zsh"
    
    if [[ -d "$oh_my_zsh_dir" ]]; then
        log_info "oh-my-zsh is already installed"
        return 0
    fi
    
    log_info "Installing oh-my-zsh..."
    
    # Download and install oh-my-zsh non-interactively
    if command -v curl >/dev/null 2>&1; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    elif command -v wget >/dev/null 2>&1; then
        RUNZSH=no CHSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        log_error "Neither curl nor wget is available. Cannot install oh-my-zsh."
        return 1
    fi
    
    log_success "oh-my-zsh installed successfully"
}

# Install useful ZSH plugins
install_zsh_plugins() {
    local oh_my_zsh_custom="$HOME/.oh-my-zsh/custom"
    
    # zsh-autosuggestions
    local autosuggestions_dir="$oh_my_zsh_custom/plugins/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
    else
        log_info "zsh-autosuggestions already installed"
    fi
    
    # zsh-syntax-highlighting
    local syntax_highlighting_dir="$oh_my_zsh_custom/plugins/zsh-syntax-highlighting"
    if [[ ! -d "$syntax_highlighting_dir" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_highlighting_dir"
    else
        log_info "zsh-syntax-highlighting already installed"
    fi
    
    # powerlevel10k theme
    local p10k_dir="$oh_my_zsh_custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        log_info "Installing powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    else
        log_info "powerlevel10k already installed"
    fi
}

# Setup ZSH configuration
setup_zshrc() {
    local zshrc_path="$HOME/.zshrc"
    
    # Backup existing .zshrc
    backup_file "$zshrc_path"
    
    # Create new .zshrc
    log_info "Creating new .zshrc configuration..."
    
    cat > "$zshrc_path" << 'EOF'
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins to load
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
    history-substring-search
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

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
        if [[ -f "$HOME/.files/platform/macos/zsh.sh" ]]; then
            source "$HOME/.files/platform/macos/zsh.sh"
        fi
        ;;
    Linux*)
        if [[ -f "$HOME/.files/platform/ubuntu/zsh.sh" ]]; then
            source "$HOME/.files/platform/ubuntu/zsh.sh"
        fi
        ;;
esac

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nano'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
    
    log_success "ZSH configuration created at $zshrc_path"
}

# Create a basic p10k configuration
setup_p10k_config() {
    local p10k_config="$HOME/.p10k.zsh"
    
    if [[ -f "$p10k_config" ]]; then
        log_info "Powerlevel10k configuration already exists"
        return 0
    fi
    
    log_info "Creating basic Powerlevel10k configuration..."
    
    cat > "$p10k_config" << 'EOF'
# Powerlevel10k configuration file

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Left prompt elements
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir                   # current directory
  vcs                   # git status
  prompt_char           # prompt symbol
)

# Right prompt elements
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                # exit code of the last command
  command_execution_time # duration of the last command
  background_jobs       # presence of background jobs
  time                  # current time
)

# Prompt colors
typeset -g POWERLEVEL9K_DIR_FOREGROUND=blue
typeset -g POWERLEVEL9K_VCS_FOREGROUND=green
typeset -g POWERLEVEL9K_TIME_FOREGROUND=cyan

# Prompt symbol
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=red
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'

# Add newline before each prompt
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Show command execution time if >= 3 seconds
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3

# Git settings
typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

# Instant prompt mode
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Disable hot reload for better performance
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
EOF
    
    log_success "Basic Powerlevel10k configuration created"
}

# Main ZSH setup function
main() {
    log_info "Setting up ZSH configuration for platform: $PLATFORM"
    
    # Install oh-my-zsh
    install_oh_my_zsh
    
    # Install plugins
    install_zsh_plugins
    
    # Setup .zshrc
    setup_zshrc
    
    # Setup p10k config
    setup_p10k_config
    
    log_success "ZSH setup completed successfully!"
    log_info "Run 'p10k configure' to customize your prompt further"
}

# Run main function
main "$@"
