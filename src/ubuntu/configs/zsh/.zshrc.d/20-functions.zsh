# Useful functions for Ubuntu systems

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find file by name in current directory tree
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directory by name in current directory tree
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Create a backup of a file
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backup created: $1.backup.$(date +%Y%m%d_%H%M%S)"
    else
        echo "File '$1' not found"
    fi
}

# Show directory sizes sorted
dirsize() {
    du -sh ${1:-.}/* 2>/dev/null | sort -h
}

# Quick HTTP server in current directory
serve() {
    local port="${1:-8000}"
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Python is required but not installed"
    fi
}

# Show all listening ports
listening() {
    sudo lsof -iTCP -sTCP:LISTEN -P -n
}

# Get public IP
pubip() {
    curl -s https://api.ipify.org || curl -s https://icanhazip.com
}

# Show PATH entries on separate lines
showpath() {
    echo "$PATH" | tr ':' '\n'
}

# Colorized man pages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# Quick git commit with message
qcommit() {
    git add -A && git commit -m "$1" && git push
}

# Show most used commands from history
histop() {
    history | awk '{print $2}' | sort | uniq -c | sort -rn | head -20
}