#!/usr/bin/env bash

# Ubuntu Platform Setup Script
# Ubuntu-specific configurations and package installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo -e "${BLUE}[UBUNTU]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[UBUNTU]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[UBUNTU]${NC} $1"
}

log_error() {
    echo -e "${RED}[UBUNTU]${NC} $1"
}

# Check if running on Ubuntu
check_ubuntu() {
    if ! command -v lsb_release >/dev/null 2>&1; then
        log_error "lsb_release not found. This script is designed for Ubuntu."
        return 1
    fi
    
    if ! lsb_release -i | grep -q "Ubuntu"; then
        log_error "This script is designed for Ubuntu systems."
        return 1
    fi
    
    local version
    version=$(lsb_release -rs)
    log_info "Detected Ubuntu $version"
}

# Update package lists
update_packages() {
    log_info "Updating package lists..."
    sudo apt update
    log_success "Package lists updated"
}

# Install essential packages
install_essentials() {
    log_info "Installing essential packages..."
    
    local packages=(
        "curl"
        "wget"
        "git"
        "vim"
        "nano"
        "htop"
        "tree"
        "unzip"
        "zip"
        "build-essential"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "bash-completion"
        "command-not-found"
        "xclip"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log_info "Installing $package..."
            sudo apt install -y "$package"
        else
            log_info "$package is already installed"
        fi
    done
    
    log_success "Essential packages installed"
}

# Install development tools
install_dev_tools() {
    log_info "Installing development tools..."
    
    # Node.js (via NodeSource)
    if ! command -v node >/dev/null 2>&1; then
        log_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
        log_success "Node.js installed"
    else
        log_info "Node.js is already installed"
    fi
    
    # Python development tools
    if ! command -v python3-pip >/dev/null 2>&1; then
        log_info "Installing Python development tools..."
        sudo apt install -y python3-pip python3-venv python3-dev
        log_success "Python development tools installed"
    else
        log_info "Python development tools are already installed"
    fi
    
    # Docker (optional)
    if ! command -v docker >/dev/null 2>&1; then
        read -p "Would you like to install Docker? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installing Docker..."
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo usermod -aG docker "$USER"
            log_success "Docker installed. Please log out and back in to use Docker without sudo."
        fi
    else
        log_info "Docker is already installed"
    fi
}

# Setup Ubuntu-specific shell configurations
setup_shell_configs() {
    log_info "Setting up Ubuntu-specific shell configurations..."
    
    # Create ZSH configuration
    cat > "$SCRIPT_DIR/zsh.sh" << 'EOF'
#!/usr/bin/env bash
# Ubuntu-specific ZSH configuration

# Ubuntu-specific aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias apt-update='sudo apt update && sudo apt upgrade'
alias apt-search='apt search'
alias apt-install='sudo apt install'
alias apt-remove='sudo apt remove'
alias apt-autoremove='sudo apt autoremove'
alias apt-clean='sudo apt autoclean'

# System service management
alias systemctl-status='sudo systemctl status'
alias systemctl-start='sudo systemctl start'
alias systemctl-stop='sudo systemctl stop'
alias systemctl-restart='sudo systemctl restart'
alias systemctl-enable='sudo systemctl enable'
alias systemctl-disable='sudo systemctl disable'

# Network management
alias netplan-apply='sudo netplan apply'
alias ufw-status='sudo ufw status'
alias ufw-enable='sudo ufw enable'
alias ufw-disable='sudo ufw disable'

# Package management
alias snap-list='snap list'
alias snap-install='sudo snap install'
alias snap-remove='sudo snap remove'

# System information
alias ubuntu-version='lsb_release -a'
alias kernel-version='uname -r'

# Clipboard integration
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# File manager
alias open='xdg-open'

# Process management
alias psa='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Memory and disk
alias meminfo='free -m -l -t'
alias diskinfo='df -h'
alias cpuinfo='lscpu'

# Network tools
alias ports='netstat -tulanp'
alias listening='netstat -tlnp'
EOF
    
    # Create Bash configuration
    cat > "$SCRIPT_DIR/bash.sh" << 'EOF'
#!/usr/bin/env bash
# Ubuntu-specific Bash configuration

# Source the ZSH configuration (same aliases work for both)
source "$(dirname "${BASH_SOURCE[0]}")/zsh.sh"

# Bash-specific Ubuntu settings
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Enable command-not-found
if [ -f /usr/share/command-not-found/command-not-found ]; then
    command_not_found_handle() {
        /usr/share/command-not-found/command-not-found -- "$1"
        return $?
    }
fi
EOF
    
    # Create profile configuration
    cat > "$SCRIPT_DIR/profile.sh" << 'EOF'
#!/usr/bin/env bash
# Ubuntu-specific profile configuration

# Add snap to PATH if it exists
if [ -d "/snap/bin" ]; then
    export PATH="/snap/bin:$PATH"
fi

# Add local bin to PATH
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Flatpak support
if [ -d "/var/lib/flatpak/exports/bin" ]; then
    export PATH="/var/lib/flatpak/exports/bin:$PATH"
fi
if [ -d "$HOME/.local/share/flatpak/exports/bin" ]; then
    export PATH="$HOME/.local/share/flatpak/exports/bin:$PATH"
fi

# Ubuntu-specific environment variables
export BROWSER='xdg-open'
export UBUNTU_MENUPROXY=0  # Disable global menu for some applications
EOF
    
    log_success "Ubuntu-specific shell configurations created"
}

# Configure Ubuntu-specific settings
configure_ubuntu_settings() {
    log_info "Configuring Ubuntu-specific settings..."
    
    # Update command-not-found database
    if command -v update-command-not-found >/dev/null 2>&1; then
        log_info "Updating command-not-found database..."
        sudo update-command-not-found
    fi
    
    # Configure Git (if not already configured)
    if ! git config --global user.name >/dev/null 2>&1; then
        log_info "Git user configuration not found. You may want to run:"
        log_info "  git config --global user.name 'Your Name'"
        log_info "  git config --global user.email 'your.email@example.com'"
    fi
    
    log_success "Ubuntu-specific settings configured"
}

# Main Ubuntu setup function
main() {
    log_info "Starting Ubuntu-specific setup..."
    
    # Check if running on Ubuntu
    check_ubuntu
    
    # Update packages
    update_packages
    
    # Install essential packages
    install_essentials
    
    # Install development tools
    install_dev_tools
    
    # Setup shell configurations
    setup_shell_configs
    
    # Configure Ubuntu settings
    configure_ubuntu_settings
    
    log_success "Ubuntu-specific setup completed!"
    log_info "You may need to restart your terminal or log out and back in for all changes to take effect."
}

# Run main function
main "$@"
