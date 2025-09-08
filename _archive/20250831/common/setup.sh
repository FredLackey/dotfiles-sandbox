#!/usr/bin/env bash

# Common Setup Script
# Sets up shared configurations and utilities for both ZSH and Bash

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
    echo -e "${BLUE}[COMMON]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[COMMON]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[COMMON]${NC} $1"
}

log_error() {
    echo -e "${RED}[COMMON]${NC} $1"
}

# Setup Git configuration
setup_git_config() {
    log_info "Setting up Git configuration..."
    
    # Create gitconfig template if it doesn't exist
    local gitconfig_template="$SCRIPT_DIR/git/gitconfig"
    if [[ ! -f "$gitconfig_template" ]]; then
        mkdir -p "$SCRIPT_DIR/git"
        cat > "$gitconfig_template" << 'EOF'
[user]
    # Set your name and email
    # name = Your Name
    # email = your.email@example.com

[core]
    editor = nano
    autocrlf = input
    safecrlf = true
    excludesfile = ~/.gitignore_global

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = simple

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    ca = commit -a
    cm = commit -m
    cam = commit -am
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    tree = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit

[color]
    ui = auto

[color "branch"]
    current = yellow reverse
    local = yellow
    remote = green

[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold

[color "status"]
    added = yellow
    changed = green
    untracked = cyan
EOF
        log_success "Git configuration template created"
    fi
    
    # Create global gitignore
    local gitignore_global="$HOME/.gitignore_global"
    if [[ ! -f "$gitignore_global" ]]; then
        log_info "Creating global gitignore..."
        cat > "$gitignore_global" << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msm
*.msp
*.lnk

# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# Temporary folders
tmp/
temp/
EOF
        log_success "Global gitignore created"
    fi
}

# Main common setup function
main() {
    log_info "Setting up common configurations for platform: $PLATFORM"
    
    # Setup Git configuration
    setup_git_config
    
    log_success "Common setup completed successfully!"
}

# Run main function
main "$@"
