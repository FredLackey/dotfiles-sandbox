#!/usr/bin/env bash

# Common Functions
# Shared functions for both ZSH and Bash

# Create directory and cd into it
mkcd() {
    if [ $# -ne 1 ]; then
        echo "Usage: mkcd <directory_name>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ $# -ne 1 ]; then
        echo "Usage: extract <archive_file>"
        return 1
    fi
    
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.xz)        unxz "$1"        ;;
            *.exe)       cabextract "$1"  ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
        return 1
    fi
}

# Find files by name
ff() {
    if [ $# -eq 0 ]; then
        echo "Usage: ff <filename_pattern>"
        return 1
    fi
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name
fd() {
    if [ $# -eq 0 ]; then
        echo "Usage: fd <dirname_pattern>"
        return 1
    fi
    find . -type d -iname "*$1*" 2>/dev/null
}

# Find and grep in files
fgrep() {
    if [ $# -lt 2 ]; then
        echo "Usage: fgrep <pattern> <file_pattern>"
        return 1
    fi
    find . -type f -name "$2" -exec grep -l "$1" {} \; 2>/dev/null
}

# Get file size in human readable format
filesize() {
    if [ $# -ne 1 ]; then
        echo "Usage: filesize <file>"
        return 1
    fi
    
    if [ -f "$1" ]; then
        if command -v stat >/dev/null 2>&1; then
            case "$(uname -s)" in
                Darwin*)
                    stat -f%z "$1" | numfmt --to=iec-i --suffix=B
                    ;;
                Linux*)
                    stat --printf="%s" "$1" | numfmt --to=iec-i --suffix=B
                    ;;
                *)
                    ls -lh "$1" | awk '{print $5}'
                    ;;
            esac
        else
            ls -lh "$1" | awk '{print $5}'
        fi
    else
        echo "File '$1' not found"
        return 1
    fi
}

# Create a backup of a file
backup() {
    if [ $# -ne 1 ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    
    if [ -f "$1" ]; then
        cp "$1" "${1}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backup created: ${1}.backup.$(date +%Y%m%d_%H%M%S)"
    else
        echo "File '$1' not found"
        return 1
    fi
}

# Show PATH in a readable format
path() {
    echo "$PATH" | tr ':' '\n' | nl
}

# Show disk usage of current directory
usage() {
    du -h --max-depth=1 2>/dev/null | sort -hr
}

# Show top 10 largest files in current directory
largest() {
    find . -type f -exec ls -s {} \; 2>/dev/null | sort -n -r | head -10
}

# Show top 10 most used commands from history
topcmds() {
    if [ -f ~/.bash_history ]; then
        history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
    elif [ -f ~/.zsh_history ]; then
        fc -l 1 | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
    else
        echo "No history file found"
        return 1
    fi
}

# Quick web search (opens in default browser)
google() {
    if [ $# -eq 0 ]; then
        echo "Usage: google <search_terms>"
        return 1
    fi
    
    local search_terms
    search_terms=$(echo "$*" | sed 's/ /+/g')
    
    case "$(uname -s)" in
        Darwin*)
            open "https://www.google.com/search?q=$search_terms"
            ;;
        Linux*)
            xdg-open "https://www.google.com/search?q=$search_terms"
            ;;
        *)
            echo "Search URL: https://www.google.com/search?q=$search_terms"
            ;;
    esac
}

# Get weather information
weather() {
    local location="${1:-}"
    if command -v curl >/dev/null 2>&1; then
        if [ -n "$location" ]; then
            curl -s "wttr.in/$location"
        else
            curl -s "wttr.in"
        fi
    else
        echo "curl is required for weather function"
        return 1
    fi
}

# Generate a random password
genpass() {
    local length="${1:-16}"
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
    elif [ -f /dev/urandom ]; then
        tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' < /dev/urandom | head -c "$length"
        echo
    else
        echo "Cannot generate password: no suitable random source found"
        return 1
    fi
}

# Show system information
sysinfo() {
    echo "System Information:"
    echo "=================="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes."}')"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo "Date: $(date)"
    
    if command -v free >/dev/null 2>&1; then
        echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    fi
    
    if command -v df >/dev/null 2>&1; then
        echo "Disk Usage:"
        df -h | grep -E '^/dev/' | awk '{print "  " $1 ": " $3 "/" $2 " (" $5 ")"}'
    fi
}

# Port management functions
port() {
    local action="$1"
    local port_num="$2"
    
    case "$action" in
        "check"|"c")
            if [ -z "$port_num" ]; then
                echo "Usage: port check <port_number>"
                return 1
            fi
            if command -v lsof >/dev/null 2>&1; then
                lsof -i ":$port_num"
            elif command -v netstat >/dev/null 2>&1; then
                netstat -tuln | grep ":$port_num"
            else
                echo "Neither lsof nor netstat available"
                return 1
            fi
            ;;
        "kill"|"k")
            if [ -z "$port_num" ]; then
                echo "Usage: port kill <port_number>"
                return 1
            fi
            if command -v lsof >/dev/null 2>&1; then
                local pid
                pid=$(lsof -ti ":$port_num")
                if [ -n "$pid" ]; then
                    kill -9 "$pid"
                    echo "Killed process $pid using port $port_num"
                else
                    echo "No process found using port $port_num"
                fi
            else
                echo "lsof not available"
                return 1
            fi
            ;;
        *)
            echo "Usage: port {check|kill} <port_number>"
            echo "  check: Show what's using the port"
            echo "  kill:  Kill process using the port"
            return 1
            ;;
    esac
}

# Git helper functions
if command -v git >/dev/null 2>&1; then
    # Git status with branch info
    gst() {
        git status
        echo
        git log --oneline -5
    }
    
    # Git commit with automatic add
    gac() {
        if [ $# -eq 0 ]; then
            echo "Usage: gac <commit_message>"
            return 1
        fi
        git add .
        git commit -m "$*"
    }
    
    # Git branch cleanup (delete merged branches)
    gbclean() {
        git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
    }
    
    # Git log with graph
    glog() {
        git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit "${@:-HEAD~10..HEAD}"
    }
fi

# Docker helper functions
if command -v docker >/dev/null 2>&1; then
    # Docker cleanup
    dclean() {
        echo "Cleaning up Docker..."
        docker system prune -f
        docker volume prune -f
        docker network prune -f
    }
    
    # Docker stats for all containers
    dstats() {
        docker stats --no-stream
    }
    
    # Docker logs with follow
    dlogf() {
        if [ $# -ne 1 ]; then
            echo "Usage: dlogf <container_name_or_id>"
            return 1
        fi
        docker logs -f "$1"
    }
fi

# Network functions
myip() {
    echo "Public IP:"
    if command -v curl >/dev/null 2>&1; then
        curl -s https://ipinfo.io/ip
        echo
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://ipinfo.io/ip
        echo
    else
        echo "curl or wget required"
    fi
    
    echo "Local IP:"
    case "$(uname -s)" in
        Darwin*)
            ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
            ;;
        Linux*)
            hostname -I | tr ' ' '\n' | grep -v '^$'
            ;;
        *)
            echo "Platform not supported"
            ;;
    esac
}

# Process management
pskill() {
    if [ $# -ne 1 ]; then
        echo "Usage: pskill <process_name>"
        return 1
    fi
    
    local pids
    pids=$(pgrep -f "$1")
    
    if [ -n "$pids" ]; then
        echo "Found processes:"
        ps -p "$pids" -o pid,ppid,cmd
        echo
        read -p "Kill these processes? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill $pids
            echo "Processes killed"
        else
            echo "Cancelled"
        fi
    else
        echo "No processes found matching '$1'"
    fi
}

# Text processing functions
lowercase() {
    if [ $# -eq 0 ]; then
        tr '[:upper:]' '[:lower:]'
    else
        echo "$*" | tr '[:upper:]' '[:lower:]'
    fi
}

uppercase() {
    if [ $# -eq 0 ]; then
        tr '[:lower:]' '[:upper:]'
    else
        echo "$*" | tr '[:lower:]' '[:upper:]'
    fi
}

# URL encode/decode
urlencode() {
    if [ $# -eq 0 ]; then
        echo "Usage: urlencode <string>"
        return 1
    fi
    python3 -c "import urllib.parse; print(urllib.parse.quote('$*'))" 2>/dev/null || \
    node -e "console.log(encodeURIComponent('$*'))" 2>/dev/null || \
    echo "Python3 or Node.js required for URL encoding"
}

urldecode() {
    if [ $# -eq 0 ]; then
        echo "Usage: urldecode <encoded_string>"
        return 1
    fi
    python3 -c "import urllib.parse; print(urllib.parse.unquote('$*'))" 2>/dev/null || \
    node -e "console.log(decodeURIComponent('$*'))" 2>/dev/null || \
    echo "Python3 or Node.js required for URL decoding"
}
