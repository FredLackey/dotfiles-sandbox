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
# Generated by Powerlevel10k configuration wizard.
# Based on romkatv/powerlevel10k/config/p10k-lean.zsh.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS

  # Zsh >= 5.1 is required.
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    prompt_char             # prompt symbol
  )

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    virtualenv              # python virtual environment
    context                 # user@hostname
    time                    # current time
  )

  # Basic style options that define the overall look of your prompt.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt except the first.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Magenta prompt symbol if the last command succeeded, red if failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=magenta
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='Ⅴ'

  # Grey Python Virtual Environment.
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # Blue current directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=blue

  # Context format when root: user@hostname. The first part will be styled as a string.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  # Context format when not root: user@hostname. The first part will be styled as a string.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  # Don't show context unless root or in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # Grey Git prompt.
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=76

  # Disable async loading indicator to make directories that aren't Git repositories
  # indistinguishable from large Git repositories without known state.
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

  # Don't wait for Git status even for a millisecond, so that prompt always updates
  # asynchronously when Git state changes.
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0

  # Cyan ahead/behind arrows.
  typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND=cyan

  # Don't show remote branch, current tag or stashes.
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname)
  typeset -g POWERLEVEL9K_VCS_{TAG,REMOTE_BRANCH,REMOTE_URL,UNTRACKED,CONFLICTED,STAGED,UNSTAGED}_ICON=
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON=

  # Show status of repositories of these types. You can add svn and/or hg if you are
  # using them. If you do, your prompt may become slow even when your current directory
  # isn't in an svn or hg reposotiry, because powerlevel10k will run `svn status` and/or
  # `hg status` on every directory change. This is unavoidable.
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # These settings are used for repositories other than Git or when gitstatusd fails and
  # Powerlevel10k has to fall back to using vcs_info.
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND,STASH,LOCAL_BRANCH,REMOTE_BRANCH,TAG}_CONTENT_EXPANSION=

  # Grey current time.
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

  # Transient prompt works similarly to the builtin transient_rprompt option. It trims down prompt
  # when accepting a command line. Supported values:
  #
  #   - off:      Don't change prompt when accepting a command line.
  #   - always:   Trim down prompt when accepting a command line.
  #   - same-dir: Trim down prompt when accepting a command line unless this is the first command
  #               typed after changing current working directory.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # Instant prompt mode.
  #   - off:     Disable instant prompt. Choose this if you've tried instant prompt and found
  #              it incompatible with your zsh configuration files.
  #   - quiet:   Enable instant prompt and don't print warnings when detecting console output
  #              during zsh initialization. Choose this if you've read and understood
  #              https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt.
  #   - verbose: Enable instant prompt and print a warning when detecting console output during
  #              zsh initialization. Choose this if you've never tried instant prompt, live
  #              dangerously, and do like shell prompts.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
  # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
  # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
  # really need it.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
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
