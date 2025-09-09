# Common aliases for Ubuntu systems

# Directory navigation
alias cd..='cd ..'
alias pd='pushd'
alias pop='popd'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# System information
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'

# Network
alias ports='netstat -tulanp'
alias myip='curl -s https://api.ipify.org && echo'

# Package management
alias update='sudo apt-get update'
alias upgrade='sudo apt-get update && sudo apt-get upgrade'
alias search='apt-cache search'
alias install='sudo apt-get install'

# Development
alias g='git'
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'

# Text editors
alias v='vim'
alias vi='vim'

# System services
alias sysctl='systemctl'
alias sysstatus='systemctl status'
alias sysstart='sudo systemctl start'
alias sysstop='sudo systemctl stop'
alias sysrestart='sudo systemctl restart'

# Useful shortcuts
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'

# Safety nets
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'