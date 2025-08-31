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

# Terminal color support detection and forcing
export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"

# Force color support for common terminals
case "$TERM" in
    xterm*|screen*|tmux*|rxvt*)
        export TERM="xterm-256color"
        ;;
esac

# Colors for ls - Enhanced Darcula-inspired colors
case "$(uname -s)" in
    Darwin*)
        export CLICOLOR=1
        # Darcula-inspired LSCOLORS: directories=blue, symlinks=magenta, executables=green, etc.
        export LSCOLORS=ExGxBxDxCxegedabagacad
        ;;
    Linux*)
        # Darcula-inspired LS_COLORS with vibrant colors
        export LS_COLORS='rs=0:di=01;34:ln=01;35:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36'
        ;;
esac

# Grep colors - Enhanced for better visibility
export GREP_COLOR='1;33'  # Bright yellow instead of green
export GREP_COLORS='ms=01;33:mc=01;33:sl=:cx=:fn=35:ln=32:bn=32:se=36'
export GREP_OPTIONS='--color=auto'

# Man page colors (for better readability)
export LESS_TERMCAP_mb=$'\e[1;32m'     # begin blinking
export LESS_TERMCAP_md=$'\e[1;32m'     # begin bold
export LESS_TERMCAP_me=$'\e[0m'        # end mode
export LESS_TERMCAP_se=$'\e[0m'        # end standout-mode
export LESS_TERMCAP_so=$'\e[01;33m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'        # end underline
export LESS_TERMCAP_us=$'\e[1;4;31m'   # begin underline

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

# Bat settings (if bat is available) - Darcula-like theme
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="Monokai Extended"
    export BAT_STYLE="numbers,changes,header"
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
