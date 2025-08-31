#!/usr/bin/env bash

# Common Environment Variables
# Shared exports for both ZSH and Bash

# Default editor
export EDITOR='nano'
export VISUAL='nano'

# Language and locale
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Less settings
export LESS='-R -i -w -M -z-4'
export LESSOPEN='|~/.lessfilter %s'

# Pager
export PAGER='less'

# Colors for ls
case "$(uname -s)" in
    Darwin*)
        export CLICOLOR=1
        export LSCOLORS=ExFxBxDxCxegedabagacad
        ;;
    Linux*)
        export LS_COLORS='di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
        ;;
esac

# Grep colors
export GREP_COLOR='1;32'
export GREP_OPTIONS='--color=auto'

# Development paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Node.js settings (if node is available)
if command -v node >/dev/null 2>&1; then
    export NODE_OPTIONS='--max-old-space-size=4096'
fi

# Python settings
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Go settings (if go is available)
if command -v go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# Rust settings (if cargo is available)
if [ -d "$HOME/.cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Java settings
if [ -n "$JAVA_HOME" ]; then
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Platform-specific exports
case "$(uname -s)" in
    Darwin*)
        # macOS specific exports
        
        # Homebrew
        if [ -d "/opt/homebrew" ]; then
            export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
            export HOMEBREW_PREFIX="/opt/homebrew"
            export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
            export HOMEBREW_REPOSITORY="/opt/homebrew"
            export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
            export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
        elif [ -d "/usr/local/Homebrew" ]; then
            export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
            export HOMEBREW_PREFIX="/usr/local"
            export HOMEBREW_CELLAR="/usr/local/Cellar"
            export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
        fi
        
        # macOS GNU tools (if installed via Homebrew)
        if [ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]; then
            export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
        fi
        if [ -d "/opt/homebrew/opt/gnu-tar/libexec/gnubin" ]; then
            export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
        fi
        if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
            export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
        fi
        
        # macOS specific settings
        export BROWSER='open'
        ;;
    Linux*)
        # Linux specific exports
        
        # Snap packages
        if [ -d "/snap/bin" ]; then
            export PATH="/snap/bin:$PATH"
        fi
        
        # Flatpak
        if [ -d "/var/lib/flatpak/exports/bin" ]; then
            export PATH="/var/lib/flatpak/exports/bin:$PATH"
        fi
        if [ -d "$HOME/.local/share/flatpak/exports/bin" ]; then
            export PATH="$HOME/.local/share/flatpak/exports/bin:$PATH"
        fi
        
        # Linux specific settings
        export BROWSER='xdg-open'
        ;;
esac

# Docker settings (if docker is available)
if command -v docker >/dev/null 2>&1; then
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
fi

# SSH settings
export SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# GPG settings
export GPG_TTY=$(tty)

# FZF settings (if fzf is available)
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" -not -path "*/node_modules/*" -not -path "*/\.vscode/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Ripgrep settings (if rg is available)
if command -v rg >/dev/null 2>&1; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# Bat settings (if bat is available)
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="TwoDark"
fi

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Development environment indicators
export DEVELOPMENT=1

# Disable telemetry for various tools
export DO_NOT_TRACK=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export GATSBY_TELEMETRY_DISABLED=1
export NEXT_TELEMETRY_DISABLED=1
export HOMEBREW_NO_ANALYTICS=1

# Performance settings
export MAKEFLAGS="-j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

# Security settings
umask 022

# Custom application paths
if [ -d "$HOME/Applications" ]; then
    export PATH="$HOME/Applications:$PATH"
fi

# Load local exports if they exist
if [ -f "$HOME/.exports.local" ]; then
    source "$HOME/.exports.local"
fi
