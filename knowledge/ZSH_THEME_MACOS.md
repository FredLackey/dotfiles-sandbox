# ZSH Terminal Theming on macOS

## Overview

This document explains how to programmatically change the background color and theme of the default macOS Terminal when using zsh, similar to how it's done in the legacy bash configuration files.

## Background: Legacy Bash Approach

The legacy bash dotfiles use:
- **bash_prompt**: Sets up git repository details, enables color support, and configures PS1/PS2/PS4 prompts
- **bash_colors**: Configures LSCOLORS and enables colorized `ls` output with `-G` flag

## ZSH Terminal Theming Methods

### Method 1: ANSI Escape Sequences in .zshrc

Add these to your `.zshrc` file to set colors using ANSI escape sequences:

```bash
# Enable color support
autoload -U colors && colors

# Set terminal to support 256 colors
export TERM="xterm-256color"

# Enable colorized output for ls (similar to bash_colors)
export CLICOLOR=1
export LSCOLORS="gxfxcxdxcxegedabagacad"
alias ls="ls -G"

# Configure prompt with colors
PROMPT="%{$fg[orange]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}:%{$fg[green]%}%~%{$reset_color%} $ "

# For 256-color support (more granular control)
PROMPT="%F{208}%n%f@%F{226}%m%f:%F{118}%~%f $ "
```

### Method 2: Terminal Profile Changes via osascript

You can programmatically change Terminal.app's profile/theme from within `.zshrc`:

```bash
# Function to set Terminal profile
set_terminal_profile() {
    local profile="$1"
    osascript -e "tell application \"Terminal\" to set current settings of front window to settings set \"${profile}\""
}

# Set a specific profile on shell startup
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    set_terminal_profile "Pro"  # or "Basic", "Homebrew", "Man Page", etc.
fi

# Dark mode detection and auto-switching
if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        set_terminal_profile "Pro"
    else
        set_terminal_profile "Basic"
    fi
fi
```

### Method 3: Direct Background Color Control

Set specific RGB background colors using osascript:

```bash
# Function to set background color (RGB values 0-65535)
set_bg_color() {
    local r=$1 g=$2 b=$3 a=${4:-65535}
    osascript -e "tell application \"Terminal\" to set background color of front window to {$r, $g, $b, $a}"
}

# Example: Set dark blue background
set_bg_color 0 0 20000 65535

# Example: Set color based on directory
chpwd() {
    case "$PWD" in
        */production*) set_bg_color 20000 0 0 65535 ;;  # Red tint for production
        */staging*)    set_bg_color 20000 20000 0 65535 ;;  # Yellow tint for staging
        *)             set_bg_color 0 0 0 65535 ;;  # Default black
    esac
}
```

### Method 4: Git-Aware Prompt (ZSH Equivalent of bash_prompt)

```bash
# Enable vcs_info for git integration
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# Configure git prompt
zstyle ':vcs_info:git:*' formats '%F{cyan}on %b%f'
zstyle ':vcs_info:git:*' actionformats '%F{cyan}on %b|%a%f'

# Git status indicators
git_status() {
    local indicators=""
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        # Check for various git states
        git diff --quiet --ignore-submodules --cached || indicators+="+"  # Staged
        git diff-files --quiet --ignore-submodules -- || indicators+="!"  # Modified
        [[ -n $(git ls-files --others --exclude-standard) ]] && indicators+="?"  # Untracked
        git rev-parse --verify refs/stash &>/dev/null && indicators+="$"  # Stashed
    fi
    [[ -n "$indicators" ]] && echo " [$indicators]"
}

# Complete prompt with git info
PROMPT='%F{208}%n%f@%F{226}%m%f:%F{118}%~%f ${vcs_info_msg_0_}$(git_status)
$ '
```

### Method 5: Terminal Title Configuration

Set the terminal window title (similar to bash PS1 terminal title):

```bash
# Set terminal title to current directory
precmd() {
    print -Pn "\e]0;%~\a"
}

# Or set to include username and host
precmd() {
    print -Pn "\e]0;%n@%m:%~\a"
}
```

## Complete .zshrc Example

```bash
#!/usr/bin/env zsh

# Enable colors
autoload -U colors && colors
export TERM="xterm-256color"

# Color support for ls (like bash_colors)
export CLICOLOR=1
export LSCOLORS="gxfxcxdxcxegedabagacad"
alias ls="ls -G"

# Git integration
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%F{cyan}on %b%f'

# Terminal profile management
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    # Auto-switch based on dark mode
    if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        osascript -e 'tell application "Terminal" to set current settings of front window to settings set "Pro"' 2>/dev/null
    fi
fi

# Set prompt with colors
PROMPT='%F{208}%n%f@%F{226}%m%f:%F{118}%~%f ${vcs_info_msg_0_}
$ '

# Terminal title
precmd() {
    print -Pn "\e]0;%~\a"
}
```

## Key Differences from Bash

1. **Color Loading**: ZSH uses `autoload -U colors && colors` instead of sourcing separate color files
2. **Prompt Variable**: ZSH uses `PROMPT` (or `PS1`) with different escape sequences
3. **Git Integration**: ZSH has built-in `vcs_info` module vs. custom functions in bash
4. **Escape Sequences**: ZSH uses `%F{color}` or `%{$fg[color]%}` instead of bash's `\[\033[color\]`
5. **Directory Change Hook**: ZSH has `chpwd()` function that runs on directory change

## Terminal.app Limitations

- Terminal.app supports most ANSI escape sequences but not all (e.g., ESC [s and ESC [u for cursor save/restore)
- Limited to predefined profiles or RGB color values via osascript
- Cannot change system-level Terminal preferences programmatically without System Events access

## Best Practices

1. Check for Terminal.app before applying macOS-specific settings:
   ```bash
   [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && # Terminal.app specific code
   ```

2. Make color changes idempotent - check current state before modifying

3. Use functions for reusable color/theme operations

4. Consider using Oh My Zsh or Powerlevel10k for more advanced theming capabilities

5. Test escape sequences compatibility: Terminal.app handles ESC 7/8 but not CSI s/u

## References

- ANSI Escape Codes: Color codes range from 30-37 (foreground) and 40-47 (background)
- 256-color support: Use `%F{0-255}` for foreground, `%K{0-255}` for background
- RGB values for osascript: 0-65535 per channel (16-bit)
- Terminal profiles: "Basic", "Grass", "Homebrew", "Man Page", "Novel", "Ocean", "Pro", "Red Sands", "Silver Aerogel", "Solid Colors"