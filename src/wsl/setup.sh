#!/bin/bash

# WSL Ubuntu-specific setup script for dotfiles
# This script configures WSL Ubuntu for full-stack development with Windows integration
# Includes full IDE environment with Neovim, ZSH, and all development tools

# Don't exit on error - we want to continue even if some components fail
# set -e  # Disabled to allow partial installations

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source output formatting utilities if available
if [ -f "$SCRIPT_DIR/../utils/output.sh" ]; then
    source "$SCRIPT_DIR/../utils/output.sh"
else
    # Fallback to basic output functions
    print_in_color() {
        printf "%b" \
            "$(tput setaf "$2" 2> /dev/null)" \
            "$1" \
            "$(tput sgr0 2> /dev/null)"
    }
    
    print_error() {
        print_in_color "   [✖] $1\n" 1
    }
    
    print_success() {
        print_in_color "   [✔] $1\n" 2
    }
    
    print_info() {
        print_in_color "   [i] $1\n" 5
    }
    
    print_warning() {
        print_in_color "   [!] $1\n" 3
    }
    
    print_title() {
        print_in_color "\n   $1\n\n" 5
    }
    
    execute() {
        local -r CMDS="$1"
        local -r MSG="${2:-$1}"
        local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
        local exitCode=0
        
        echo "   [⋯] $MSG"
        
        # Execute command silently (sudo already authenticated)
        if eval "$CMDS" > "$TMP_FILE" 2>&1; then
            echo -e "\033[1A\033[K   [✔] $MSG"
            exitCode=0
        else
            echo -e "\033[1A\033[K   [✖] $MSG"
            exitCode=1
            # Show error details
            while read -r line; do
                echo "   ↳ $line"
            done < "$TMP_FILE"
        fi
        
        rm -rf "$TMP_FILE"
        return $exitCode
    }
fi

# Common utility function
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for sudo password upfront and keep it alive
ask_for_sudo() {
    # Check if sudo requires a password
    if sudo -n true 2>/dev/null; then
        # Passwordless sudo detected
        print_success "Passwordless sudo detected"
        return 0
    fi
    
    # Password is required
    print_info "Administrator privileges will be required..."
    
    # Prompt for password
    if ! sudo -v; then
        print_error "Failed to authenticate with sudo"
        print_info "If sudo is not needed, press Ctrl+C to skip"
        exit 1
    fi
    
    # Keep sudo alive until the script finishes
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

# Verify we're running in WSL
verify_wsl() {
    # Check if we're on Linux
    if [ "$(uname -s)" != "Linux" ]; then
        print_error "This script is for WSL Ubuntu only"
        exit 1
    fi
    
    # Check for WSL markers
    local is_wsl=false
    
    if [ -f /proc/version ]; then
        if grep -qi "microsoft\|wsl" /proc/version; then
            is_wsl=true
        fi
    fi
    
    if [ "$is_wsl" = false ]; then
        print_error "WSL not detected. Please use src/ubuntu/setup.sh for standard Ubuntu"
        exit 1
    fi
    
    # Detect WSL version
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        print_info "Detected WSL 2"
    else
        print_info "Detected WSL 1"
    fi
    
    print_success "Verified WSL Ubuntu environment"
}

# Configure system locale
configure_locale() {
    print_title "System Locale Configuration"
    
    # First, check if en_US.UTF-8 locale exists
    if ! locale -a 2>/dev/null | grep -q "^en_US.utf8"; then
        print_info "Configuring system locale..."
        
        # Install locales package if not present
        if ! dpkg -l | grep -q "^ii  locales "; then
            execute \
                "sudo apt-get install -qqy locales" \
                "Installing locales package"
        fi
        
        # Generate locale (this may take a moment)
        execute \
            "sudo locale-gen en_US.UTF-8" \
            "Generating en_US.UTF-8 locale"
        
        # Reconfigure locales
        execute \
            "sudo dpkg-reconfigure --frontend=noninteractive locales" \
            "Reconfiguring locales"
    else
        print_success "en_US.UTF-8 locale already exists"
    fi
    
    # Update default locale
    execute \
        "sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en" \
        "Setting default locale to en_US.UTF-8"
    
    # Set for current session (without execute to avoid subshell issues)
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANGUAGE=en_US:en
    
    # Add locale exports to bashrc if not present
    if ! grep -q "export LANG=en_US.UTF-8" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" <<'EOF'

# System Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US:en
EOF
        print_info "Added locale exports to .bashrc"
    fi
    
    # Also add to .profile for login shells
    if ! grep -q "export LANG=en_US.UTF-8" "$HOME/.profile" 2>/dev/null; then
        cat >> "$HOME/.profile" <<'EOF'

# System Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US:en
EOF
        print_info "Added locale exports to .profile"
    fi
    
    print_success "Locale configured"
}

# Update package lists
update_package_lists() {
    execute \
        "sudo apt-get update -qq" \
        "Updating package lists"
}

# Install Git and essential build tools
install_git() {
    print_title "Git & Build Essentials"
    
    # Check if git is already installed
    if check_command git; then
        print_success "Git (already installed)"
        execute \
            "sudo apt-get install -qqy --only-upgrade git" \
            "Updating Git"
    else
        execute \
            "sudo apt-get install -qqy git" \
            "Git"
    fi
    
    # Install build essentials
    local packages=(
        "build-essential"  # Compiler and build tools
        "curl"            # Data transfer tool
        "wget"            # Download tool
        "software-properties-common"  # Repository management
        "apt-transport-https"  # HTTPS support for apt
        "ca-certificates"  # SSL certificates
        "gnupg"           # GNU Privacy Guard
        "lsb-release"     # LSB release info
    )
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            print_success "$package (already installed)"
        else
            execute \
                "sudo apt-get install -qqy '$package'" \
                "$package"
        fi
    done
}

# Install essential command-line tools
install_essential_tools() {
    print_title "Essential Tools"
    
    local tools=(
        "tree"      # Directory listing
        "htop"      # Process viewer
        "ncdu"      # Disk usage analyzer
        "tmux"      # Terminal multiplexer
        "screen"    # Terminal multiplexer alternative
        "vim"       # Text editor
        "nano"      # Simple text editor
        "jq"        # JSON processor
        "unzip"     # Archive extraction
        "zip"       # Archive creation
        "net-tools" # Network utilities
        "wslu"      # WSL utilities for Windows integration
    )
    
    for tool in "${tools[@]}"; do
        if dpkg -l | grep -q "^ii  $tool "; then
            print_success "$tool (already installed)"
        else
            execute \
                "sudo apt-get install -qqy '$tool'" \
                "$tool"
        fi
    done
}

# Configure WSL-specific settings
configure_wsl() {
    print_title "WSL Configuration"
    
    # Create wsl.conf if it doesn't exist
    if [ ! -f /etc/wsl.conf ]; then
        print_info "Creating /etc/wsl.conf..."
        sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[network]
generateHosts=true
generateResolvConf=true

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
mountFsTab=true
EOF
        print_success "WSL configuration created"
    else
        print_info "WSL configuration already exists"
    fi
    
    # Configure Windows interoperability
    configure_windows_interop
}

# Configure Windows interoperability
configure_windows_interop() {
    print_info "Configuring Windows interoperability..."
    
    # Set up Windows paths access
    if [ -d "/mnt/c" ]; then
        print_info "Windows C: drive accessible at /mnt/c"
        
        # Create symbolic links for common Windows directories
        if [ ! -L "$HOME/windows" ]; then
            # Find Windows user directory
            WIN_USER=""
            for dir in /mnt/c/Users/*; do
                if [ -d "$dir" ] && [ "$(basename "$dir")" != "Public" ] && [ "$(basename "$dir")" != "Default" ]; then
                    WIN_USER="$(basename "$dir")"
                    break
                fi
            done
            
            if [ -n "$WIN_USER" ]; then
                ln -sf "/mnt/c/Users/$WIN_USER" "$HOME/windows"
                print_info "Created symbolic link to Windows user directory"
            fi
        fi
    fi
    
    # Configure Git to work with Windows line endings
    git config --global core.autocrlf input
    print_info "Configured Git for Windows line endings"
    
    # Set up clipboard integration if available
    if check_command clip.exe; then
        print_info "Windows clipboard integration available"
        
        # Add clipboard aliases if not already present
        if ! grep -q "# WSL Clipboard Integration" "$HOME/.bashrc" 2>/dev/null; then
            cat >> "$HOME/.bashrc" <<'EOF'

# WSL Clipboard Integration
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command "Get-Clipboard"'
EOF
            print_info "Added clipboard aliases"
        fi
    fi
    
    print_success "Windows interoperability configured"
}

# Initialize Git repository for dotfiles
initialize_git_repo() {
    print_title "Git Repository"
    
    cd "$DOTFILES_DIR"
    
    # Check if already a git repository
    if [ -d ".git" ]; then
        print_success "Git repository (already initialized)"
        
        # Check if remote origin exists
        if ! git remote | grep -q "origin"; then
            execute \
                "git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git'" \
                "Adding git remote origin"
        else
            print_success "Git remote origin (already configured)"
        fi
        
        # Set branch tracking
        if ! git config branch.main.remote &>/dev/null; then
            execute \
                "git branch --set-upstream-to=origin/main main 2>/dev/null || true" \
                "Setting branch tracking"
        fi
    else
        # Initialize new repository
        execute \
            "git init" \
            "Initializing Git repository"
        
        # Add remote
        execute \
            "git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git'" \
            "Adding git remote origin"
        
        # Fetch from origin to establish connection
        execute \
            "git fetch origin main" \
            "Fetching from remote repository"
        
        # Set main branch to track origin
        execute \
            "git branch --set-upstream-to=origin/main main 2>/dev/null || git checkout -b main --track origin/main 2>/dev/null || true" \
            "Setting up branch tracking"
        
        print_info "Git repository initialized for future updates"
        print_info "Use 'git pull' to get latest changes from GitHub"
    fi
    
    cd - >/dev/null
}

# Install and configure ZSH
install_zsh() {
    print_title "ZSH Installation"
    
    if check_command zsh; then
        local current_version=$(zsh --version 2>/dev/null | awk '{print $2}')
        print_success "ZSH already installed (version $current_version)"
        
        # Update to latest version if available
        execute \
            "sudo apt-get install -qqy --only-upgrade zsh" \
            "Checking for ZSH updates"
    else
        # Install ZSH
        execute \
            "sudo apt-get install -qqy zsh" \
            "Installing ZSH"
        
        # Verify installation
        if check_command zsh; then
            local version=$(zsh --version 2>/dev/null | awk '{print $2}')
            print_success "ZSH installed successfully (version $version)"
        else
            print_error "Failed to install ZSH"
            return 1
        fi
    fi
    
    # Ensure ZSH is in /etc/shells
    local zsh_path=$(which zsh 2>/dev/null)
    if [ -n "$zsh_path" ]; then
        if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
            execute \
                "echo '$zsh_path' | sudo tee -a /etc/shells > /dev/null" \
                "Adding ZSH to /etc/shells"
        else
            print_success "ZSH already in /etc/shells"
        fi
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_title "Oh My Zsh Installation"
    
    # Check if Oh My Zsh is already installed
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
        return 0
    fi
    
    # Ensure prerequisites
    if ! check_command zsh; then
        print_error "ZSH is required for Oh My Zsh"
        return 1
    fi
    
    if ! check_command git; then
        print_error "Git is required for Oh My Zsh"
        return 1
    fi
    
    # Back up existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        execute \
            "cp '$HOME/.zshrc' '$HOME/.zshrc.pre-oh-my-zsh'" \
            "Backing up existing .zshrc"
    fi
    
    # Download and run Oh My Zsh installer
    print_info "Installing Oh My Zsh..."
    
    # Set environment variables for unattended installation
    export RUNZSH=no  # Don't run ZSH after installation
    export CHSH=no    # Don't change shell (we handle this separately)
    
    if check_command curl; then
        execute \
            "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended" \
            "Installing Oh My Zsh"
    else
        execute \
            "sh -c \"\$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended" \
            "Installing Oh My Zsh"
    fi
    
    # Check if installation was successful
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_error "Oh My Zsh installation failed"
        return 1
    fi
    
    print_success "Oh My Zsh installed successfully"
    
    # Install popular third-party plugins
    install_oh_my_zsh_plugins
}

# Install Oh My Zsh plugins
install_oh_my_zsh_plugins() {
    print_info "Installing Oh My Zsh plugins..."
    
    # Ensure custom plugins directory exists
    local custom_plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom_plugins_dir"
    
    # Install zsh-autosuggestions
    if [ ! -d "$custom_plugins_dir/zsh-autosuggestions" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-autosuggestions '$custom_plugins_dir/zsh-autosuggestions'" \
            "Installing zsh-autosuggestions"
    else
        print_success "zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$custom_plugins_dir/zsh-syntax-highlighting" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-syntax-highlighting '$custom_plugins_dir/zsh-syntax-highlighting'" \
            "Installing zsh-syntax-highlighting"
    else
        print_success "zsh-syntax-highlighting already installed"
    fi
    
    # Update .zshrc to include the plugins if not already configured
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "plugins=.*zsh-autosuggestions" "$HOME/.zshrc"; then
            # Update the plugins line
            sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
            print_success "Updated .zshrc with custom plugins"
        fi
    fi
}

# Install Powerline fonts
install_powerline_fonts() {
    print_title "Powerline Fonts"
    
    # Check if fonts are already installed
    if fc-list | grep -qi "powerline\|meslo\|nerd"; then
        print_success "Powerline fonts already installed"
        return 0
    fi
    
    # Install fonts-powerline package
    execute \
        "sudo apt-get install -qqy fonts-powerline" \
        "Installing powerline fonts"
    
    # Update font cache
    execute \
        "fc-cache -fv" \
        "Updating font cache"
    
    print_info "Note: You may need to configure Windows Terminal to use a Powerline font"
}

# Configure shell
configure_shell() {
    print_title "Shell Configuration"
    
    # Set default editor
    if ! grep -q "EDITOR=" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export EDITOR=vim' >> "$HOME/.bashrc"
        print_info "Set default editor to vim"
    fi
    
    # Enable color prompt if not already enabled
    if [ -f "$HOME/.bashrc" ]; then
        sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' "$HOME/.bashrc"
    fi
    
    # Add WSL-specific aliases
    if ! grep -q "# WSL Aliases" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" <<'EOF'

# WSL Aliases
alias explorer='explorer.exe'
alias code='code.exe'
alias notepad='notepad.exe'
alias open='explorer.exe'
EOF
        print_info "Added WSL-specific aliases"
    fi
    
    # Copy shell configurations from Ubuntu configs
    local ubuntu_configs="$SCRIPT_DIR/../ubuntu/configs"
    
    # Copy bash configuration
    if [ -f "$ubuntu_configs/bash/bashrc-custom" ]; then
        if ! grep -q "# Custom Bash Configuration" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# Custom Bash Configuration" >> "$HOME/.bashrc"
            cat "$ubuntu_configs/bash/bashrc-custom" >> "$HOME/.bashrc"
            print_success "Applied custom bash configuration"
        fi
    fi
    
    # Copy ZSH configuration if Oh My Zsh is installed
    if [ -d "$HOME/.oh-my-zsh" ] && [ -f "$ubuntu_configs/ohmyzsh/zshrc-ohmyzsh-template" ]; then
        execute \
            "cp '$ubuntu_configs/ohmyzsh/zshrc-ohmyzsh-template' '$HOME/.zshrc'" \
            "Installing custom ZSH configuration"
    fi
    
    print_success "Shell configuration completed"
}

# Install Neovim
install_neovim() {
    print_title "Neovim Installation"
    
    # Check if Neovim is already installed
    if check_command nvim; then
        local current_version=$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")
        print_success "Neovim already installed (version $current_version)"
        
        # Define minimum required version (0.9.0 for modern IDE features)
        local min_version="0.9.0"
        
        # Compare versions (basic comparison - may need refinement for edge cases)
        if [ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" = "$min_version" ]; then
            print_success "Neovim version $current_version meets requirements"
            
            # Just ensure config directory exists and set alternatives
            mkdir -p "$HOME/.config/nvim"
            
            # Set Neovim as default editor alternatives (idempotent)
            execute \
                "sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 100" \
                "Setting Neovim as editor alternative"
            
            execute \
                "sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 100" \
                "Setting Neovim as vi alternative"
            
            return 0
        else
            print_info "Neovim version $current_version is below minimum required ($min_version)"
            print_info "Upgrading Neovim..."
        fi
    else
        print_info "Neovim not found, installing..."
    fi
    
    # Only add PPA if we need to install or upgrade
    if ! grep -q "neovim-ppa/stable" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        execute \
            "sudo add-apt-repository -y ppa:neovim-ppa/stable && sudo apt-get update -qq" \
            "Adding Neovim PPA repository"
    else
        print_success "Neovim PPA already configured"
        # Just update package lists to get latest version
        execute \
            "sudo apt-get update -qq" \
            "Updating package lists for Neovim"
    fi
    
    # Install or upgrade Neovim
    execute \
        "sudo apt-get install -qqy neovim" \
        "Installing/Upgrading Neovim"
    
    # Verify installation
    if check_command nvim; then
        local version=$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        print_success "Neovim ready (version $version)"
    else
        print_error "Failed to install Neovim"
        return 1
    fi
    
    # Create Neovim config directory
    mkdir -p "$HOME/.config/nvim"
    
    # Set Neovim as default editor alternatives
    execute \
        "sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 100" \
        "Setting Neovim as editor alternative"
    
    execute \
        "sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 100" \
        "Setting Neovim as vi alternative"
}

# Install Neovim IDE dependencies
install_neovim_dependencies() {
    print_title "Neovim IDE Dependencies"
    
    local deps=(
        "ripgrep"        # Fast grep alternative (required for Telescope)
        "fd-find"        # Fast find alternative (required for Telescope)
        "xclip"          # Clipboard support
        "python3-pip"    # Python package manager
        "python3-venv"   # Python virtual environments
        "nodejs"         # Node.js runtime (for many LSP servers)
        "npm"            # Node package manager
    )
    
    for dep in "${deps[@]}"; do
        if dpkg -l | grep -q "^ii  $dep "; then
            print_success "$dep (already installed)"
        else
            execute \
                "sudo apt-get install -qqy '$dep'" \
                "$dep"
        fi
    done
    
    # Install lazygit
    if ! check_command lazygit; then
        print_info "Installing lazygit..."
        
        # Add lazygit repository
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -oP '"tag_name": "v\K[^"]*' || echo "0.40.2")
        
        execute \
            "curl -Lo /tmp/lazygit.tar.gz 'https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz' && \
             sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit && \
             rm /tmp/lazygit.tar.gz" \
            "Installing lazygit"
    else
        print_success "lazygit (already installed)"
    fi
    
    # Create fd symlink (Ubuntu uses fdfind)
    if check_command fdfind && ! check_command fd; then
        execute \
            "sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd" \
            "Creating fd symlink"
    fi
    
    print_success "Neovim IDE dependencies installed"
}

# Configure Neovim as IDE
configure_neovim_ide() {
    print_title "Neovim IDE Configuration"
    
    # Ensure Neovim is installed
    if ! check_command nvim; then
        print_error "Neovim is not installed"
        return 1
    fi
    
    # Create Neovim config directory
    mkdir -p "$HOME/.config/nvim"
    
    # Copy IDE configuration from Ubuntu configs
    local ubuntu_nvim_config="$SCRIPT_DIR/../ubuntu/configs/nvim-ide"
    
    if [ -d "$ubuntu_nvim_config" ]; then
        print_info "Installing Neovim IDE configuration..."
        
        # Backup existing configuration if present
        if [ -d "$HOME/.config/nvim" ] && [ "$(ls -A $HOME/.config/nvim 2>/dev/null)" ]; then
            execute \
                "mv '$HOME/.config/nvim' '$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)'" \
                "Backing up existing Neovim configuration"
        fi
        
        # Copy the entire nvim-ide configuration
        execute \
            "cp -r '$ubuntu_nvim_config' '$HOME/.config/nvim'" \
            "Installing Neovim IDE configuration"
        
        print_success "Neovim IDE configuration installed"
        print_info "Neovim will install plugins on first launch"
        print_info "Run 'nvim' and wait for plugin installation to complete"
    else
        print_warning "Neovim IDE configuration not found in Ubuntu configs"
    fi
}

# Install tmux configuration
install_tmux() {
    print_title "Tmux Configuration"
    
    # Ensure tmux is installed
    if ! check_command tmux; then
        execute \
            "sudo apt-get install -qqy tmux" \
            "Installing tmux"
    else
        print_success "tmux (already installed)"
    fi
    
    # Copy tmux configuration from Ubuntu configs
    local ubuntu_tmux_config="$SCRIPT_DIR/../ubuntu/configs/tmux/tmux.conf"
    
    if [ -f "$ubuntu_tmux_config" ]; then
        execute \
            "cp '$ubuntu_tmux_config' '$HOME/.tmux.conf'" \
            "Installing tmux configuration"
    else
        print_warning "Tmux configuration not found"
    fi
}

# Install programming languages and tools
install_programming_tools() {
    print_title "Programming Languages & Tools"
    
    # Install each component with error handling
    install_nodejs || print_warning "Node.js installation had issues, continuing..."
    install_java || print_warning "Java installation had issues, continuing..."
    install_python_dev || print_warning "Python tools installation had issues, continuing..."
    install_docker || print_warning "Docker installation had issues, continuing..."
    install_build_tools || print_warning "Build tools installation had issues, continuing..."
    
    return 0  # Always return success to continue
}

# Install Node Version Manager (nvm) and Node.js
install_nodejs() {
    print_info "Installing Node Version Manager (nvm) and Node.js..."
    
    # Target Node.js version
    local NODE_VERSION="20"  # Node.js 20.x LTS
    local NVM_VERSION="0.39.7"  # Latest stable nvm version
    
    # Check if Node.js is already managed by nvm
    if [ -d "$HOME/.nvm" ]; then
        # Source nvm to check current setup
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Check if node is from nvm (path should contain .nvm)
        if check_command node && which node | grep -q ".nvm"; then
            print_success "Node.js is already managed by nvm"
            local current_node_version=$(node --version 2>/dev/null)
            print_info "Current Node.js version: $current_node_version"
        fi
    fi
    
    # Only remove system Node.js if:
    # 1. It exists as a system package
    # 2. It's NOT managed by nvm (or nvm doesn't exist)
    if dpkg -l | grep -q "^ii  nodejs "; then
        # Check if this is truly a system package and not nvm-managed
        if ! which node 2>/dev/null | grep -q ".nvm"; then
            print_info "Found system-installed Node.js (not managed by nvm)"
            print_info "Removing system Node.js to avoid conflicts with nvm..."
            execute \
                "sudo apt-get remove -qqy nodejs npm" \
                "Removing system Node.js"
            
            # Clean up old nodejs sources
            execute \
                "sudo rm -f /etc/apt/sources.list.d/nodesource.list*" \
                "Cleaning up NodeSource repository"
        else
            print_success "Node.js is managed by nvm, keeping current setup"
        fi
    fi
    
    # Install nvm
    if [ ! -d "$HOME/.nvm" ]; then
        print_info "Installing Node Version Manager (nvm)..."
        
        # Download and install nvm
        execute \
            "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash" \
            "Installing nvm"
        
        # Source nvm for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    else
        print_success "nvm already installed"
        
        # Source nvm for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
    
    # Add nvm to shell configs if not already present
    configure_nvm_in_shells
    
    # Install Node.js using nvm
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        print_info "Installing Node.js v${NODE_VERSION} using nvm..."
        
        # Source nvm and install Node (can't use execute function due to subshell)
        (
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install ${NODE_VERSION} >/dev/null 2>&1
        )
        if [ $? -eq 0 ]; then
            print_success "Installing Node.js v${NODE_VERSION}"
        else
            print_error "Installing Node.js v${NODE_VERSION}"
            return 1
        fi
        
        # Use the installed version
        (
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm use ${NODE_VERSION} >/dev/null 2>&1
        )
        if [ $? -eq 0 ]; then
            print_success "Activating Node.js v${NODE_VERSION}"
        else
            print_error "Activating Node.js v${NODE_VERSION}"
        fi
        
        # Set as default
        (
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm alias default ${NODE_VERSION} >/dev/null 2>&1
        )
        if [ $? -eq 0 ]; then
            print_success "Setting Node.js v${NODE_VERSION} as default"
        else
            print_error "Setting Node.js v${NODE_VERSION} as default"
        fi
        
        # Verify installation by sourcing nvm and checking
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        if command -v node >/dev/null 2>&1; then
            local node_version=$(node --version 2>/dev/null)
            local npm_version=$(npm --version 2>/dev/null)
            print_success "Node.js $node_version and npm $npm_version installed via nvm"
        else
            print_error "Failed to install Node.js via nvm"
            return 1
        fi
    else
        print_error "nvm installation failed"
        return 1
    fi
    
    # Install common global npm packages (without sudo since nvm manages this)
    local npm_packages=(
        "typescript"
        "ts-node"
        "nodemon"
        "prettier"
        "eslint"
        "yarn"
        "pnpm"
    )
    
    print_info "Installing global npm packages..."
    for package in "${npm_packages[@]}"; do
        if npm list -g "$package" &>/dev/null; then
            print_success "$package (already installed globally)"
        else
            execute \
                "npm install -g '$package'" \
                "Installing $package globally"
        fi
    done
}

# Configure nvm in shell configuration files
configure_nvm_in_shells() {
    local nvm_init='export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
    
    # Add to .bashrc if not present
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "NVM_DIR" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Node Version Manager (nvm)" >> "$HOME/.bashrc"
            echo "$nvm_init" >> "$HOME/.bashrc"
            print_success "Added nvm to .bashrc"
        fi
    fi
    
    # Add to .zshrc if present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Node Version Manager (nvm)" >> "$HOME/.zshrc"
            echo "$nvm_init" >> "$HOME/.zshrc"
            print_success "Added nvm to .zshrc"
        fi
    fi
}

# Install Java
install_java() {
    print_info "Installing Java..."
    
    # Check if Java is already installed
    if check_command java; then
        local current_version=$(java -version 2>&1 | head -n1)
        print_success "Java already installed"
        print_info "Version: $current_version"
        return 0
    fi
    
    # Install OpenJDK 17 (LTS)
    execute \
        "sudo apt-get install -qqy openjdk-17-jdk openjdk-17-jre" \
        "Installing OpenJDK 17"
    
    # Set JAVA_HOME
    if ! grep -q "JAVA_HOME" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> "$HOME/.bashrc"
        echo 'export PATH=$PATH:$JAVA_HOME/bin' >> "$HOME/.bashrc"
        print_info "Set JAVA_HOME in .bashrc"
    fi
    
    # Install Maven
    if ! check_command mvn; then
        execute \
            "sudo apt-get install -qqy maven" \
            "Installing Maven"
    else
        print_success "Maven (already installed)"
    fi
    
    # Install Gradle
    if ! check_command gradle; then
        execute \
            "sudo apt-get install -qqy gradle" \
            "Installing Gradle"
    else
        print_success "Gradle (already installed)"
    fi
}

# Install Python development tools
install_python_dev() {
    print_info "Installing Python development tools..."
    
    # Ensure Python 3 is installed
    if ! check_command python3; then
        execute \
            "sudo apt-get install -qqy python3 python3-pip python3-venv" \
            "Installing Python 3"
    else
        print_success "Python 3 (already installed)"
    fi
    
    # Install pipx for isolated tool installations
    if ! check_command pipx; then
        execute \
            "sudo apt-get install -qqy pipx" \
            "Installing pipx"
        
        # Ensure pipx path is in PATH (suppress output as it's informational)
        pipx ensurepath >/dev/null 2>&1 || true
        print_success "Configuring pipx PATH"
    else
        print_success "pipx (already installed)"
        # Ensure path is configured even if pipx already installed
        pipx ensurepath >/dev/null 2>&1 || true
    fi
    
    # Install Python development packages with error handling
    local python_packages=(
        "black"           # Code formatter
        "flake8"          # Linter
        "pylint"          # Linter
        "mypy"            # Type checker
        "pytest"          # Testing framework
        "ipython"         # Enhanced Python shell
        "virtualenv"      # Virtual environment
    )
    
    for package in "${python_packages[@]}"; do
        # Try multiple installation methods
        if pipx list | grep -q "$package" 2>/dev/null; then
            print_success "$package (already installed via pipx)"
        elif pip3 show "$package" &>/dev/null; then
            print_success "$package (already installed via pip)"
        else
            # Try pipx first (preferred for tools)
            if execute "pipx install '$package'" "Installing $package via pipx"; then
                continue
            fi
            
            # Fall back to pip with --break-system-packages for Ubuntu 23.04+
            if ! execute "pip3 install --user --break-system-packages '$package' 2>/dev/null || pip3 install --user '$package'" "Installing $package via pip"; then
                print_warning "Failed to install $package"
            fi
        fi
    done
    
    # Install Python LSP server for Neovim
    print_info "Installing Python LSP server..."
    
    if ! pip3 show python-lsp-server &>/dev/null && ! pipx list | grep -q "python-lsp-server"; then
        # Try to install with pipx first
        if ! execute "pipx install 'python-lsp-server[all]'" "Installing Python LSP server via pipx"; then
            # Fall back to pip
            execute \
                "pip3 install --user --break-system-packages 'python-lsp-server[all]' 2>/dev/null || pip3 install --user 'python-lsp-server[all]'" \
                "Installing Python LSP server via pip"
        fi
    else
        print_success "Python LSP server (already installed)"
    fi
}

# Install Docker (WSL-specific)
install_docker() {
    print_info "Installing Docker for WSL..."
    
    # Check if Docker Desktop is installed on Windows
    if check_command docker.exe; then
        print_success "Docker Desktop detected on Windows"
        print_info "Docker commands will use Docker Desktop"
        
        # Create docker alias to use Windows Docker
        if ! grep -q "alias docker='docker.exe'" "$HOME/.bashrc" 2>/dev/null; then
            echo "alias docker='docker.exe'" >> "$HOME/.bashrc"
            echo "alias docker-compose='docker-compose.exe'" >> "$HOME/.bashrc"
            print_info "Created Docker aliases for Windows Docker Desktop"
        fi
        
        return 0
    fi
    
    # Check if Docker is already installed
    if check_command docker; then
        print_success "Docker already installed"
        local docker_version=$(docker --version 2>/dev/null)
        print_info "Version: $docker_version"
        return 0
    fi
    
    # Install Docker CE in WSL (alternative to Docker Desktop)
    print_info "Installing Docker CE in WSL..."
    
    # Remove any existing Docker GPG key file first to avoid any prompts
    sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null || true
    
    # Add Docker's official GPG key (using --batch and --yes to avoid all prompts)
    execute \
        "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" \
        "Adding Docker GPG key"
    
    # Add Docker repository
    execute \
        "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" \
        "Adding Docker repository"
    
    # Update package lists
    execute \
        "sudo apt-get update -qq" \
        "Updating package lists for Docker"
    
    # Install Docker
    execute \
        "sudo apt-get install -qqy docker-ce docker-ce-cli containerd.io docker-compose-plugin" \
        "Installing Docker CE"
    
    # Add user to docker group
    if ! groups | grep -q docker; then
        execute \
            "sudo usermod -aG docker $USER" \
            "Adding user to docker group"
        print_info "You'll need to log out and back in for docker group changes to take effect"
    fi
    
    print_warning "Note: Docker in WSL requires either Docker Desktop or manual daemon start"
}

# Install build tools
install_build_tools() {
    print_info "Installing additional build tools..."
    
    local tools=(
        "make"
        "cmake"
        "autoconf"
        "automake"
        "pkg-config"
        "libtool"
    )
    
    for tool in "${tools[@]}"; do
        if dpkg -l | grep -q "^ii  $tool "; then
            print_success "$tool (already installed)"
        else
            execute \
                "sudo apt-get install -qqy '$tool'" \
                "$tool"
        fi
    done
}

# Install LSP servers for Neovim
install_lsp_servers() {
    print_title "LSP Servers Installation"
    
    # Source nvm for this function
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # TypeScript/JavaScript LSP (no sudo needed with nvm)
    if check_command npm; then
        if ! npm list -g typescript-language-server &>/dev/null; then
            execute \
                "npm install -g typescript-language-server typescript" \
                "Installing TypeScript language server"
        else
            print_success "TypeScript language server (already installed)"
        fi
        
        # Vue language server
        if ! npm list -g @vue/language-server &>/dev/null; then
            execute \
                "npm install -g @vue/language-server" \
                "Installing Vue language server"
        else
            print_success "Vue language server (already installed)"
        fi
        
        # ESLint and Prettier for code formatting (already installed in nodejs packages)
        if ! npm list -g eslint &>/dev/null; then
            execute \
                "npm install -g eslint" \
                "Installing ESLint"
        else
            print_success "ESLint (already installed)"
        fi
        
        if ! npm list -g prettier &>/dev/null; then
            execute \
                "npm install -g prettier" \
                "Installing Prettier"
        else
            print_success "Prettier (already installed)"
        fi
    fi
    
    # Java LSP (jdtls) - Note: This will be installed via Mason.nvim
    print_info "Java language server (jdtls) will be installed via Mason.nvim in Neovim"
    
    # Lua language server
    install_lua_language_server
    
    # Bash language server
    if check_command npm; then
        if ! npm list -g bash-language-server &>/dev/null; then
            execute \
                "npm install -g bash-language-server" \
                "Installing Bash language server"
        else
            print_success "Bash language server (already installed)"
        fi
    fi
    
    # YAML language server
    if check_command npm; then
        if ! npm list -g yaml-language-server &>/dev/null; then
            execute \
                "npm install -g yaml-language-server" \
                "Installing YAML language server"
        else
            print_success "YAML language server (already installed)"
        fi
    fi
    
    # JSON language server
    if check_command npm; then
        if ! npm list -g vscode-langservers-extracted &>/dev/null; then
            execute \
                "npm install -g vscode-langservers-extracted" \
                "Installing JSON/HTML/CSS language servers"
        else
            print_success "JSON/HTML/CSS language servers (already installed)"
        fi
    fi
    
    print_info "Note: Additional LSP servers can be installed via Mason.nvim (:Mason in Neovim)"
}

# Install Lua language server
install_lua_language_server() {
    print_info "Installing Lua language server..."
    
    # Check if already installed
    if [ -d "/usr/local/share/lua-language-server" ]; then
        print_success "Lua language server (already installed)"
        return 0
    fi
    
    # Get latest release URL
    local LUA_LS_VERSION=$(curl -s "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" | grep -oP '"tag_name": "\K[^"]*' || echo "3.7.4")
    local DOWNLOAD_URL="https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz"
    
    # Download and extract
    execute \
        "sudo mkdir -p /usr/local/share/lua-language-server && \
         curl -sL '$DOWNLOAD_URL' | sudo tar xz -C /usr/local/share/lua-language-server" \
        "Downloading and extracting Lua language server"
    
    # Create symlink
    execute \
        "sudo ln -sf /usr/local/share/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server" \
        "Creating lua-language-server symlink"
    
    print_success "Lua language server installed"
}

# Create development directories
create_dev_directories() {
    print_title "Development Directories"
    
    local dirs=(
        "$HOME/projects"
        "$HOME/workspace"
        "$HOME/.local/bin"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            execute \
                "mkdir -p '$dir'" \
                "Creating $(basename $dir) directory"
        else
            print_success "$(basename $dir) directory (already exists)"
        fi
    done
    
    # Add .local/bin to PATH if not already there
    if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        print_info "Added ~/.local/bin to PATH"
    fi
}

# Set ZSH as default shell
set_default_shell() {
    print_title "Default Shell Configuration"
    
    # Check if ZSH is installed
    if ! check_command zsh; then
        print_info "ZSH not installed, keeping bash as default shell"
        return 0
    fi
    
    local zsh_path=$(which zsh 2>/dev/null)
    local current_shell=$(echo $SHELL)
    
    # Check if ZSH is already the default shell
    if [ "$current_shell" = "$zsh_path" ]; then
        print_success "ZSH is already your default shell"
        return 0
    fi
    
    # Check if ZSH is in /etc/shells
    if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
        print_warning "ZSH not found in /etc/shells, cannot set as default"
        return 1
    fi
    
    # Change default shell to ZSH
    print_info "Setting ZSH as default shell..."
    
    # Use chsh to change shell (non-interactive)
    if command -v chsh >/dev/null 2>&1; then
        # For WSL, we can use chsh without password in most cases
        sudo chsh -s "$zsh_path" "$USER" 2>/dev/null || \
        chsh -s "$zsh_path" 2>/dev/null || {
            print_warning "Could not automatically change shell to ZSH"
            print_info "You can manually change it with: chsh -s $(which zsh)"
            return 1
        }
        
        if [ $? -eq 0 ]; then
            print_success "Default shell changed to ZSH"
            print_info "Change will take effect on next login"
        fi
    else
        print_warning "chsh command not available"
        print_info "To change your shell manually, add this to Windows Terminal settings:"
        print_info "  \"commandline\": \"wsl.exe -d Ubuntu -- /usr/bin/zsh\""
    fi
    
    return 0
}

# Main function
main() {
    print_info "Starting WSL Ubuntu setup..."
    print_info "This will configure a complete development environment"
    
    # Ask for sudo password upfront
    ask_for_sudo
    
    # Verify we're in WSL
    verify_wsl
    
    # Configure locale first to avoid warnings
    configure_locale
    
    # Update package lists
    update_package_lists
    
    # Install Git and build essentials
    install_git
    
    # Install essential tools
    install_essential_tools
    
    # Configure WSL-specific settings
    configure_wsl
    
    # Initialize Git repository
    initialize_git_repo
    
    # Install and configure ZSH
    install_zsh
    install_oh_my_zsh
    install_powerline_fonts
    
    # Configure shell
    configure_shell
    
    # Install Neovim and dependencies
    install_neovim
    install_neovim_dependencies
    configure_neovim_ide
    
    # Install tmux
    install_tmux
    
    # Install programming tools
    install_programming_tools
    
    # Install LSP servers
    install_lsp_servers
    
    # Create development directories
    create_dev_directories
    
    # Set ZSH as default shell if installed
    set_default_shell
    
    print_success "WSL Ubuntu setup completed!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Restart your WSL terminal or run: source ~/.bashrc"
    print_info "2. Launch Neovim with 'nvim' to install IDE plugins"
    print_info "3. Configure Windows Terminal to use a Powerline font"
    
    # Check if shell change requires re-login
    if [ "$SHELL" != "$(which zsh 2>/dev/null)" ] && check_command zsh; then
        print_info ""
        print_warning "Shell has been changed to ZSH. Please restart your terminal for the change to take effect."
    fi
    print_info ""
    print_info "IDE Keybindings (Space as leader key):"
    print_info "  Space e    - Toggle file explorer"
    print_info "  Space ff   - Find files"
    print_info "  Space fg   - Find text in files (grep)"
    print_info "  Space t    - Toggle terminal"
    print_info "  :ToggleTerm - Open terminal window"
    print_info ""
    print_info "Some changes may require WSL restart:"
    print_info "  Run 'wsl --shutdown' from Windows PowerShell and restart"
    
    return 0
}

# Execute main function when script is run directly
main "$@"