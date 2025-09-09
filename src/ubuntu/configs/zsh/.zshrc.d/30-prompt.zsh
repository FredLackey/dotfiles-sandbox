# Enhanced prompt configuration for ZSH

# Git prompt support
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# Configure vcs_info for git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '!'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' %F{yellow}[%b%u%c]%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}[%b|%a%u%c]%f'

# Enhanced prompt with git support
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f${vcs_info_msg_0_}$ '

# Right side prompt with time
RPROMPT='%F{240}%*%f'

# Enable command execution time display
setopt PROMPT_SUBST
preexec() {
    timer=$SECONDS
}

precmd() {
    if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        if [ $timer_show -ge 3 ]; then
            export RPROMPT="%F{cyan}${timer_show}s%f %F{240}%*%f"
        else
            export RPROMPT="%F{240}%*%f"
        fi
        unset timer
    fi
}