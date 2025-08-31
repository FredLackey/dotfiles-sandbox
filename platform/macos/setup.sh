#!/usr/bin/env bash

# macOS Platform Setup Script
# macOS-specific configurations and package installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo -e "${BLUE}[MACOS]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[MACOS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[MACOS]${NC} $1"
}

log_error() {
    echo -e "${RED}[MACOS]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS systems."
        return 1
    fi
    
    local version
    version=$(sw_vers -productVersion)
    log_info "Detected macOS $version"
}

# Install or update Homebrew
install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        log_info "Homebrew is already installed"
        log_info "Updating Homebrew..."
        brew update
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        log_success "Homebrew installed"
    fi
}

# Install essential packages via Homebrew
install_essentials() {
    log_info "Installing essential packages via Homebrew..."
    
    local packages=(
        "git"
        "curl"
        "wget"
        "tree"
        "htop"
        "jq"
        "ripgrep"
        "fd"
        "bat"
        "eza"
        "fzf"
        "gnu-sed"
        "gnu-tar"
        "coreutils"
        "findutils"
        "grep"
    )
    
    for package in "${packages[@]}"; do
        if ! brew list "$package" &>/dev/null; then
            log_info "Installing $package..."
            brew install "$package"
        else
            log_info "$package is already installed"
        fi
    done
    
    log_success "Essential packages installed"
}

# Install development tools
install_dev_tools() {
    log_info "Installing development tools..."
    
    local dev_packages=(
        "node"
        "python@3.11"
        "go"
        "rust"
        "docker"
        "docker-compose"
        "git-lfs"
        "gh"
        "vim"
        "neovim"
    )
    
    for package in "${dev_packages[@]}"; do
        if ! brew list "$package" &>/dev/null; then
            read -p "Would you like to install $package? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installing $package..."
                brew install "$package"
            fi
        else
            log_info "$package is already installed"
        fi
    done
    
    log_success "Development tools installation completed"
}

# Install useful GUI applications
install_gui_apps() {
    log_info "Installing GUI applications..."
    
    local cask_apps=(
        "visual-studio-code"
        "google-chrome"
        "firefox"
        "iterm2"
        "rectangle"
        "the-unarchiver"
        "vlc"
    )
    
    for app in "${cask_apps[@]}"; do
        if ! brew list --cask "$app" &>/dev/null; then
            read -p "Would you like to install $app? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installing $app..."
                brew install --cask "$app"
            fi
        else
            log_info "$app is already installed"
        fi
    done
    
    log_success "GUI applications installation completed"
}

# Configure macOS system settings
configure_macos_settings() {
    log_info "Configuring macOS system settings..."
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions in Finder
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    
    # Enable tap to click for trackpad
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Show battery percentage in menu bar
    defaults write com.apple.menuextra.battery ShowPercent -string "YES"
    
    # Set dock to auto-hide
    defaults write com.apple.dock autohide -bool true
    
    # Remove dock delay
    defaults write com.apple.dock autohide-delay -float 0
    
    # Set dock size
    defaults write com.apple.dock tilesize -int 48
    
    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    
    # Don't show Dashboard as a Space
    defaults write com.apple.dock dashboard-in-overlay -bool true
    
    # Restart affected applications
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    
    log_success "macOS system settings configured"
}

# Setup macOS-specific shell configurations
setup_shell_configs() {
    log_info "Setting up macOS-specific shell configurations..."
    
    # Create ZSH configuration
    cat > "$SCRIPT_DIR/zsh.sh" << 'EOF'
#!/usr/bin/env bash
# macOS-specific ZSH configuration

# macOS-specific aliases
alias finder='open -a Finder'
alias chrome='open -a "Google Chrome"'
alias safari='open -a Safari'
alias code='open -a "Visual Studio Code"'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Use GNU tools if available (installed via Homebrew)
if command -v gls >/dev/null 2>&1; then
    alias ls='gls --color=auto'
    alias ll='gls -alF --color=auto'
    alias la='gls -A --color=auto'
    alias l='gls -CF --color=auto'
fi

if command -v gsed >/dev/null 2>&1; then
    alias sed='gsed'
fi

if command -v gtar >/dev/null 2>&1; then
    alias tar='gtar'
fi

if command -v ggrep >/dev/null 2>&1; then
    alias grep='ggrep --color=auto'
fi

# Use eza if available (better ls)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -la'
    alias la='eza -a'
    alias lt='eza -T'
    alias tree='eza -T'
fi

# Use bat if available (better cat)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# Use ripgrep if available (better grep)
if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
fi

# Use fd if available (better find)
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

# Homebrew aliases
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewinfo='brew info'
alias brewsearch='brew search'
alias brewinstall='brew install'
alias brewuninstall='brew uninstall'
alias brewlist='brew list'
alias brewservices='brew services'

# System aliases
alias cpu='top -o cpu'
alias mem='top -o rsize'
alias diskusage='df -h'
alias battery='pmset -g batt'
alias sleep='pmset sleepnow'
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Network aliases
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias wifi='airport -s'
alias wifioff='networksetup -setairportpower en0 off'
alias wifion='networksetup -setairportpower en0 on'

# Quick access to system preferences
alias sysprefs='open -b com.apple.preference'
alias network='open -b com.apple.preference.network'
alias bluetooth='open -b com.apple.preference.bluetooth'
alias sound='open -b com.apple.preference.sound'

# macOS specific functions
function trash() {
    command mv "$@" ~/.Trash
}

function emptytrash() {
    sudo rm -rfv ~/.Trash
    sudo rm -rfv /Volumes/*/.Trashes
    sudo rm -rfv /private/var/log/asl/*.asl
    sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'
}

function update() {
    echo "Updating macOS..."
    sudo softwareupdate -i -a
    echo "Updating Homebrew..."
    brew update && brew upgrade && brew cleanup
    echo "Update complete!"
}
EOF
    
    # Create Bash configuration
    cat > "$SCRIPT_DIR/bash.sh" << 'EOF'
#!/usr/bin/env bash
# macOS-specific Bash configuration

# Source the ZSH configuration (same aliases work for both)
source "$(dirname "${BASH_SOURCE[0]}")/zsh.sh"

# Bash-specific macOS settings
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
EOF
    
    # Create profile configuration
    cat > "$SCRIPT_DIR/profile.sh" << 'EOF'
#!/usr/bin/env bash
# macOS-specific profile configuration

# Homebrew setup
if [[ $(uname -m) == "arm64" ]]; then
    # Apple Silicon Mac
    if [ -d "/opt/homebrew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    # Intel Mac
    if [ -d "/usr/local/Homebrew" ]; then
        export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    fi
fi

# Add GNU tools to PATH (if installed via Homebrew)
if [ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/gnu-tar/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/findutils/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/grep/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
fi

# macOS-specific environment variables
export BROWSER='open'
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# FZF setup (if installed via Homebrew)
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi
EOF
    
    log_success "macOS-specific shell configurations created"
}

# Main macOS setup function
main() {
    log_info "Starting macOS-specific setup..."
    
    # Check if running on macOS
    check_macos
    
    # Install Homebrew
    install_homebrew
    
    # Install essential packages
    install_essentials
    
    # Install development tools
    install_dev_tools
    
    # Install GUI applications
    install_gui_apps
    
    # Configure macOS settings
    configure_macos_settings
    
    # Setup shell configurations
    setup_shell_configs
    
    log_success "macOS-specific setup completed!"
    log_info "Some changes may require a restart to take full effect."
}

# Run main function
main "$@"
