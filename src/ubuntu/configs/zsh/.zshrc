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

# Load custom configurations from .zshrc.d directory
if [ -d "$HOME/.zshrc.d" ]; then
    # Sort files for predictable load order
    for config in "$HOME/.zshrc.d"/*.zsh; do
        # Check if glob found any files (prevents error when directory is empty)
        if [ -f "$config" ]; then
            source "$config"
        fi
    done
fi

# Source local configuration if it exists
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"