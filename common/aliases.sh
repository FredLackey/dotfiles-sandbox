#!/usr/bin/env bash

# Common Aliases
# Shared aliases for both ZSH and Bash

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List directory contents
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lah'
alias lt='ls -ltr'
alias lS='ls -lSr'

# Directory operations
alias md='mkdir -p'
alias rd='rmdir'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Process management
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Network
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# System information
alias df='df -H'
alias du='du -ch'
alias free='free -m'
alias top='top -o cpu'

# Git aliases (if git is available)
if command -v git >/dev/null 2>&1; then
    alias g='git'
    alias gs='git status'
    alias ga='git add'
    alias gaa='git add .'
    alias gc='git commit'
    alias gcm='git commit -m'
    alias gca='git commit -a'
    alias gcam='git commit -am'
    alias gp='git push'
    alias gpl='git pull'
    alias gco='git checkout'
    alias gb='git branch'
    alias gba='git branch -a'
    alias gd='git diff'
    alias gl='git log --oneline'
    alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
fi

# Docker aliases (if docker is available)
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlog='docker logs'
    alias dstop='docker stop $(docker ps -q)'
    alias drm='docker rm $(docker ps -aq)'
    alias drmi='docker rmi $(docker images -q)'
fi

# NPM aliases (if npm is available)
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install'
    alias nid='npm install --save-dev'
    alias nig='npm install -g'
    alias nr='npm run'
    alias ns='npm start'
    alias nt='npm test'
    alias nb='npm run build'
    alias nls='npm list'
    alias nlsg='npm list -g --depth=0'
fi

# Yarn aliases (if yarn is available)
if command -v yarn >/dev/null 2>&1; then
    alias y='yarn'
    alias ya='yarn add'
    alias yad='yarn add --dev'
    alias yr='yarn run'
    alias ys='yarn start'
    alias yt='yarn test'
    alias yb='yarn build'
    alias yi='yarn install'
fi

# Python aliases (if python is available)
if command -v python3 >/dev/null 2>&1; then
    alias python='python3'
    alias pip='pip3'
    alias py='python3'
    alias venv='python3 -m venv'
fi

# Platform-specific aliases
case "$(uname -s)" in
    Darwin*)
        # macOS specific aliases
        alias finder='open -a Finder'
        alias chrome='open -a "Google Chrome"'
        alias safari='open -a Safari'
        alias code='open -a "Visual Studio Code"'
        alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
        alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
        alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
        
        # Override ls for macOS
        if command -v gls >/dev/null 2>&1; then
            alias ls='gls --color=auto'
        else
            alias ls='ls -G'
        fi
        ;;
    Linux*)
        # Linux specific aliases
        alias open='xdg-open'
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
        alias apt-update='sudo apt update && sudo apt upgrade'
        alias apt-search='apt search'
        alias apt-install='sudo apt install'
        alias apt-remove='sudo apt remove'
        alias systemctl-status='sudo systemctl status'
        alias systemctl-start='sudo systemctl start'
        alias systemctl-stop='sudo systemctl stop'
        alias systemctl-restart='sudo systemctl restart'
        ;;
esac

# Editor aliases
if command -v code >/dev/null 2>&1; then
    alias edit='code'
elif command -v nano >/dev/null 2>&1; then
    alias edit='nano'
elif command -v vim >/dev/null 2>&1; then
    alias edit='vim'
else
    alias edit='vi'
fi

# Quick edit common files
alias editrc='edit ~/.bashrc ~/.zshrc 2>/dev/null || edit ~/.bashrc || edit ~/.zshrc'
alias editprofile='edit ~/.bash_profile ~/.zprofile 2>/dev/null || edit ~/.bash_profile || edit ~/.zprofile'
alias editalias='edit ~/.files/common/aliases.sh'
alias editfunc='edit ~/.files/common/functions.sh'

# Reload shell configuration
alias reload='source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null'

# Clear screen
alias c='clear'
alias cls='clear'

# History
alias h='history'
alias hg='history | grep'

# Make directory and cd into it
alias mkcd='mkdir -p "$1" && cd "$1"'

# Extract archives
alias extract='tar -xvf'

# Weather (if curl is available)
if command -v curl >/dev/null 2>&1; then
    alias weather='curl wttr.in'
fi

# IP addresses
alias myip='curl -s https://ipinfo.io/ip'
alias localip='hostname -I | cut -d" " -f1'

# Disk usage
alias ducks='du -cks * | sort -rn | head'

# Find large files
alias findbig='find . -type f -exec ls -s {} \; | sort -n -r | head -5'

# Process tree
alias pstree='pstree -p'

# Memory usage
alias meminfo='free -m -l -t'

# CPU info
alias cpuinfo='lscpu'

# Mount info
alias mountinfo='mount | column -t'
