#!/bin/bash

# Ubuntu Server-specific setup script for dotfiles
# This script configures an Ubuntu Server 22.04 LTS system for full-stack development

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
        # Passwordless sudo detected (common on EC2)
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

# Verify we're running on Ubuntu (not WSL)
verify_ubuntu() {
    # Check if we're on Linux
    if [ "$(uname -s)" != "Linux" ]; then
        print_error "This script is for Ubuntu Linux only"
        exit 1
    fi
    
    # Check for Ubuntu in os-release
    if [ -f /etc/os-release ]; then
        if ! grep -qi "ubuntu" /etc/os-release; then
            print_error "This script is for Ubuntu only"
            exit 1
        fi
    else
        print_error "Cannot determine OS distribution"
        exit 1
    fi
    
    # Make sure we're NOT in WSL
    if [ -f /proc/version ]; then
        if grep -qi "microsoft\|wsl" /proc/version; then
            print_error "WSL detected. Please use src/wsl/setup.sh instead"
            exit 1
        fi
    fi
    
    print_success "Ubuntu Server environment verified"
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

# Configure system settings
configure_system() {
    print_title "System Configuration"
    
    # Configure swap if needed
    if [ ! -f /swapfile ] && [ "$(free -m | awk '/^Mem:/{print $2}')" -lt 2048 ]; then
        execute \
            "sudo fallocate -l 2G /swapfile && \
             sudo chmod 600 /swapfile && \
             sudo mkswap /swapfile && \
             sudo swapon /swapfile" \
            "Creating 2GB swap file"
        
        # Make swap permanent
        if ! grep -q "/swapfile" /etc/fstab; then
            execute \
                "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null" \
                "Making swap permanent"
        fi
    else
        print_success "Swap (already configured)"
    fi
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
        
        # Check if version changed after update
        local new_version=$(zsh --version 2>/dev/null | awk '{print $2}')
        if [ "$current_version" != "$new_version" ]; then
            print_success "ZSH updated to version $new_version"
        fi
    else
        # Install ZSH
        execute \
            "sudo apt-get install -qqy zsh" \
            "Installing ZSH"
        
        # Verify installation and get version
        if check_command zsh; then
            local version=$(zsh --version 2>/dev/null | awk '{print $2}')
            print_success "ZSH installed successfully"
            print_success "ZSH version: $version"
        else
            print_error "Failed to install ZSH"
            return 1
        fi
    fi
    
    # Display final installed version
    local final_version=$(zsh --version 2>/dev/null | awk '{print $2}')
    local zsh_path=$(which zsh 2>/dev/null)
    if [ -n "$final_version" ] && [ -n "$zsh_path" ]; then
        print_info "ZSH $final_version installed at $zsh_path"
    fi
    
    # Ensure ZSH is in /etc/shells
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
        
        # Check for updates
        if [ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]; then
            print_info "Checking for Oh My Zsh updates..."
            # Run update in non-interactive mode
            export DISABLE_UPDATE_PROMPT=true
            sh "$HOME/.oh-my-zsh/tools/upgrade.sh" 2>/dev/null || true
        fi
        return 0
    fi
    
    # Ensure prerequisites are installed
    if ! check_command zsh; then
        print_error "ZSH is required for Oh My Zsh"
        return 1
    fi
    
    if ! check_command git; then
        print_error "Git is required for Oh My Zsh"
        return 1
    fi
    
    # Check for curl or wget
    local download_cmd=""
    if check_command curl; then
        download_cmd="curl -fsSL"
    elif check_command wget; then
        download_cmd="wget -qO-"
    else
        print_error "curl or wget is required for Oh My Zsh installation"
        return 1
    fi
    
    # Back up existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        execute \
            "cp '$HOME/.zshrc' '$HOME/.zshrc.pre-oh-my-zsh'" \
            "Backing up existing .zshrc"
    fi
    
    # Download and run Oh My Zsh installer
    # Use unattended mode to prevent interactive prompts
    print_info "Installing Oh My Zsh..."
    
    # Set environment variables for unattended installation
    export RUNZSH=no  # Don't run ZSH after installation
    export CHSH=no    # Don't change shell (we handle this separately)
    
    if [ "$download_cmd" = "curl -fsSL" ]; then
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
    
    # Copy our custom Oh My Zsh configuration template
    local ohmyzsh_config="$SCRIPT_DIR/configs/ohmyzsh/zshrc-ohmyzsh-template"
    if [ -f "$ohmyzsh_config" ]; then
        execute \
            "cp '$ohmyzsh_config' '$HOME/.zshrc'" \
            "Installing custom Oh My Zsh configuration"
    else
        print_warning "Custom Oh My Zsh configuration not found, using default"
    fi
    
    # Install popular third-party plugins
    install_oh_my_zsh_plugins
    
    # Install Powerline fonts for themes
    install_powerline_fonts
    
    return 0
}

# Install popular Oh My Zsh plugins
install_oh_my_zsh_plugins() {
    print_title "Oh My Zsh Plugins"
    
    local custom_plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # Create custom plugins directory if it doesn't exist
    if [ ! -d "$custom_plugins_dir" ]; then
        execute \
            "mkdir -p '$custom_plugins_dir'" \
            "Creating custom plugins directory"
    fi
    
    # Install zsh-autosuggestions
    if [ ! -d "$custom_plugins_dir/zsh-autosuggestions" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-autosuggestions '$custom_plugins_dir/zsh-autosuggestions'" \
            "Installing zsh-autosuggestions plugin"
    else
        print_success "zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$custom_plugins_dir/zsh-syntax-highlighting" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-syntax-highlighting '$custom_plugins_dir/zsh-syntax-highlighting'" \
            "Installing zsh-syntax-highlighting plugin"
    else
        print_success "zsh-syntax-highlighting already installed"
    fi
    
    # Install zsh-completions
    if [ ! -d "$custom_plugins_dir/zsh-completions" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-completions '$custom_plugins_dir/zsh-completions'" \
            "Installing zsh-completions plugin"
    else
        print_success "zsh-completions already installed"
    fi
}

# Install Powerline fonts for advanced themes
install_powerline_fonts() {
    print_title "Powerline Fonts"
    
    # Check if fonts-powerline package is available
    if dpkg -l | grep -q "^ii  fonts-powerline "; then
        print_success "Powerline fonts already installed"
    else
        execute \
            "sudo apt-get install -qqy fonts-powerline" \
            "Installing Powerline fonts"
    fi
    
    # For WSL, provide instructions for Windows-side installation
    if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
        print_info "WSL detected: Install Powerline fonts on Windows for proper display"
        print_info "Visit: https://github.com/powerline/fonts for Windows installation"
    fi
}

# Configure shell environment (foundation for text-based development)
configure_shell() {
    print_title "Shell Environment Configuration"
    
    # Install ZSH first
    install_zsh || {
        print_warning "ZSH installation failed, continuing with existing shell"
        return 0
    }
    
    # Install Oh My Zsh
    install_oh_my_zsh || {
        print_warning "Oh My Zsh installation failed, using basic ZSH configuration"
        
        # Fall back to basic ZSH configuration
        local zsh_configs_dir="$SCRIPT_DIR/configs/zsh"
        
        if [ -d "$zsh_configs_dir" ]; then
            # Copy main configuration files
            for config_file in .zshenv .zprofile .zshrc; do
                if [ -f "$zsh_configs_dir/$config_file" ]; then
                    if [ ! -f "$HOME/$config_file" ]; then
                        execute \
                            "cp '$zsh_configs_dir/$config_file' '$HOME/$config_file'" \
                            "Installing $config_file"
                    else
                        print_success "$config_file already exists (preserving)"
                    fi
                fi
            done
            
            # Create and populate .zshrc.d directory
            if [ ! -d "$HOME/.zshrc.d" ]; then
                execute \
                    "mkdir -p '$HOME/.zshrc.d'" \
                    "Creating ~/.zshrc.d directory"
            fi
            
            # Copy modular configuration files
            if [ -d "$zsh_configs_dir/.zshrc.d" ]; then
                for module in "$zsh_configs_dir/.zshrc.d"/*.zsh; do
                    if [ -f "$module" ]; then
                        local basename=$(basename "$module")
                        if [ ! -f "$HOME/.zshrc.d/$basename" ]; then
                            execute \
                                "cp '$module' '$HOME/.zshrc.d/$basename'" \
                                "Installing $basename"
                        else
                            print_success "$basename already exists (preserving)"
                        fi
                    fi
                done
            fi
        else
            print_warning "ZSH config templates not found at $zsh_configs_dir"
        fi
    }
    
    # Handle WSL-specific configuration
    if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
        print_info "WSL environment detected"
        
        # Add ZSH launcher to .bashrc for older WSL versions
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
                cat >> "$HOME/.bashrc" << 'EOF'

# Launch ZSH if in interactive terminal (WSL compatibility)
if test -t 1; then
    exec zsh
fi
EOF
                print_success "Added ZSH launcher to ~/.bashrc for WSL"
            fi
        fi
    fi
    
    # Set ZSH as default shell
    local zsh_path=$(which zsh 2>/dev/null)
    if [ -n "$zsh_path" ] && [ "$SHELL" != "$zsh_path" ]; then
        # Check if chsh command exists
        if ! check_command chsh; then
            execute \
                "sudo apt-get install -qqy passwd" \
                "Installing passwd package for chsh"
        fi
        
        # Change default shell
        if execute "sudo chsh -s '$zsh_path' '$USER'" "Setting ZSH as default shell"; then
            print_info "Shell change will take effect on next login"
        else
            print_warning "Failed to set default shell automatically"
            print_info "You can manually set it with: chsh -s $zsh_path"
        fi
    else
        print_success "ZSH is already the default shell"
    fi
    
    print_success "Shell environment configured with Oh My Zsh"
}

# Install Neovim
install_neovim() {
    print_title "Neovim Installation"
    
    # Check if Neovim is already installed
    if check_command nvim; then
        local current_version=$(nvim --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        print_success "Neovim already installed (version $current_version)"
        
        # Check for updates
        execute \
            "sudo apt-get install -qqy --only-upgrade neovim" \
            "Checking for Neovim updates"
    else
        # Add Neovim PPA for latest stable version
        execute \
            "sudo add-apt-repository -y ppa:neovim-ppa/stable" \
            "Adding Neovim PPA repository"
        
        execute \
            "sudo apt-get update -qq" \
            "Updating package lists"
        
        # Install Neovim
        execute \
            "sudo apt-get install -qqy neovim" \
            "Installing Neovim"
        
        if check_command nvim; then
            local version=$(nvim --version 2>/dev/null | head -n1 | cut -d' ' -f2)
            print_success "Neovim installed successfully (version $version)"
        else
            print_error "Failed to install Neovim"
            return 1
        fi
    fi
    
    # Install dependencies for Neovim
    install_neovim_dependencies
    
    # Configure Neovim
    configure_neovim
    
    return 0
}

# Install Neovim dependencies
install_neovim_dependencies() {
    print_title "Neovim Dependencies"
    
    # Build essentials for compiling Treesitter parsers
    if ! dpkg -l | grep -q "^ii  build-essential "; then
        execute \
            "sudo apt-get install -qqy build-essential" \
            "Installing build essentials for Treesitter"
    else
        print_success "Build essentials already installed"
    fi
    
    # Install gcc and g++ specifically if missing
    if ! check_command gcc; then
        execute \
            "sudo apt-get install -qqy gcc g++" \
            "Installing GCC compiler"
    else
        print_success "GCC compiler already installed"
    fi
    
    # Python support
    if check_command python3; then
        if ! python3 -c "import pynvim" 2>/dev/null; then
            execute \
                "pip3 install --user pynvim" \
                "Installing Python Neovim support"
        else
            print_success "Python Neovim support already installed"
        fi
    fi
    
    # IDE dependencies - ripgrep for telescope
    if ! check_command rg; then
        execute \
            "sudo apt-get install -qqy ripgrep" \
            "Installing ripgrep for Telescope search"
    else
        print_success "Ripgrep already installed"
    fi
    
    # fd-find for telescope file finding
    if ! check_command fd && ! check_command fdfind; then
        execute \
            "sudo apt-get install -qqy fd-find" \
            "Installing fd-find for Telescope"
        
        # Create fd symlink if needed (Ubuntu packages it as fdfind)
        if check_command fdfind && ! check_command fd; then
            execute \
                "sudo ln -s $(which fdfind) /usr/local/bin/fd" \
                "Creating fd symlink"
        fi
    else
        print_success "fd-find already installed"
    fi
    
    # xclip for system clipboard integration
    if ! check_command xclip; then
        execute \
            "sudo apt-get install -qqy xclip" \
            "Installing xclip for clipboard support"
    else
        print_success "xclip already installed"
    fi
    
    # lazygit for git integration
    if ! check_command lazygit; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        execute \
            "curl -Lo lazygit.tar.gz \"https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz\" && \
             tar xf lazygit.tar.gz lazygit && \
             sudo install lazygit /usr/local/bin && \
             rm -f lazygit.tar.gz lazygit" \
            "Installing lazygit"
    else
        print_success "lazygit already installed"
    fi
    
    # Node.js support (check if npm exists)
    if check_command npm; then
        if ! npm list -g neovim 2>/dev/null | grep -q neovim; then
            execute \
                "npm install -g neovim" \
                "Installing Node.js Neovim support"
        else
            print_success "Node.js Neovim support already installed"
        fi
    else
        print_warning "npm not found, skipping Node.js Neovim support"
    fi
    
    # Install ripgrep for fast searching
    if ! check_command rg; then
        execute \
            "sudo apt-get install -qqy ripgrep" \
            "Installing ripgrep for fast searching"
    else
        print_success "ripgrep already installed"
    fi
    
    # Install fd for file finding
    if ! check_command fdfind && ! check_command fd; then
        execute \
            "sudo apt-get install -qqy fd-find" \
            "Installing fd for file finding"
        
        # Create symlink for fd
        if [ ! -L "$HOME/.local/bin/fd" ]; then
            execute \
                "mkdir -p '$HOME/.local/bin' && ln -s $(which fdfind) '$HOME/.local/bin/fd'" \
                "Creating fd symlink"
        fi
    else
        print_success "fd already installed"
    fi
    
    # Install xclip for clipboard support (especially for WSL)
    if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
        if ! check_command xclip; then
            execute \
                "sudo apt-get install -qqy xclip xsel" \
                "Installing clipboard utilities for WSL"
        else
            print_success "Clipboard utilities already installed"
        fi
    fi
}

# Configure Neovim
configure_neovim() {
    print_title "Neovim Configuration"
    
    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_source_dir="$SCRIPT_DIR/configs/nvim"
    local nvim_ide_dir="$SCRIPT_DIR/configs/nvim-ide"
    
    # Create config directory if it doesn't exist
    if [ ! -d "$nvim_config_dir" ]; then
        execute \
            "mkdir -p '$nvim_config_dir'" \
            "Creating Neovim config directory"
    fi
    
    # Determine which configuration to use
    local config_type="basic"
    
    # Check if IDE dependencies are installed
    if check_command node && check_command npm && check_command rg && (check_command fd || check_command fdfind); then
        if dpkg -l | grep -q "^ii  build-essential "; then
            config_type="ide"
        else
            config_type="full"
        fi
    elif dpkg -l | grep -q "^ii  build-essential "; then
        config_type="full"
    else
        config_type="minimal"
    fi
    
    # Install appropriate configuration
    case "$config_type" in
        "ide")
            if [ -d "$nvim_ide_dir" ]; then
                execute \
                    "cp -r '$nvim_ide_dir'/* '$nvim_config_dir/'" \
                    "Installing Neovim IDE configuration"
                
                print_success "Full IDE Neovim configuration installed"
                print_info "Neovim will install plugins on first launch"
                print_info "LSP servers for JavaScript, TypeScript, and Java are configured"
            else
                config_type="full"  # Fallback to full if IDE config not found
            fi
            ;;
        "full")
            if [ -d "$nvim_source_dir" ]; then
                execute \
                    "cp -r '$nvim_source_dir'/* '$nvim_config_dir/'" \
                    "Installing full Neovim configuration"
                
                # Make parser installation script executable if it exists
                if [ -f "$nvim_config_dir/install-parsers.sh" ]; then
                    chmod +x "$nvim_config_dir/install-parsers.sh"
                fi
                
                print_success "Full Neovim configuration installed"
            fi
            ;;
        "minimal")
            if [ -d "$SCRIPT_DIR/configs/nvim-minimal" ]; then
                execute \
                    "cp -r '$SCRIPT_DIR/configs/nvim-minimal'/* '$nvim_config_dir/'" \
                    "Installing minimal Neovim configuration"
                
                print_success "Minimal Neovim configuration installed"
                print_info "To upgrade to full config later, install build-essential and re-run setup"
            fi
            ;;
    esac
    
    # Set Neovim as default editor if not already set
    if ! grep -q "EDITOR=nvim" "$HOME/.bashrc" 2>/dev/null && \
       ! grep -q "EDITOR=vim" "$HOME/.bashrc" 2>/dev/null; then
        execute \
            "echo 'export EDITOR=nvim' >> '$HOME/.bashrc'" \
            "Setting Neovim as default editor"
    fi
    
    # Add vi and vim aliases to use Neovim
    if check_command zsh && [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "alias vi=nvim" "$HOME/.zshrc" 2>/dev/null; then
            cat >> "$HOME/.zshrc" << 'EOF'

# Neovim aliases
alias vi='nvim'
alias vim='nvim'
EOF
            print_success "Added Neovim aliases to .zshrc"
        fi
    fi
}

# Install text-based development environment (primary focus)
install_text_based_dev_environment() {
    print_title "Text-Based Development Environment"
    
    # Install Neovim as primary IDE
    install_neovim
    
    # Install tmux for terminal multiplexing
    install_tmux
    
    # Future additions:
    # - Terminal-based file managers
    # - Additional command-line development tools
    
    print_success "Text-based development environment installed"
}

# Install tmux
install_tmux() {
    print_title "Tmux Installation"
    
    if check_command tmux; then
        print_success "Tmux already installed"
        execute \
            "sudo apt-get install -qqy --only-upgrade tmux" \
            "Checking for tmux updates"
    else
        execute \
            "sudo apt-get install -qqy tmux" \
            "Installing tmux"
    fi
    
    # Copy tmux configuration if available
    local tmux_config="$SCRIPT_DIR/configs/tmux/.tmux.conf"
    if [ -f "$tmux_config" ]; then
        execute \
            "cp '$tmux_config' '$HOME/.tmux.conf'" \
            "Installing tmux configuration"
    fi
}

# Install programming languages and tools
install_programming_tools() {
    print_title "Programming Languages & Tools"
    
    # Install Node.js and npm
    install_nodejs || print_warning "Node.js installation had issues, continuing..."
    
    # Install Java development tools
    install_java || print_warning "Java installation had issues, continuing..."
    
    # Install Python development tools
    install_python_dev || print_warning "Python tools installation had issues, continuing..."
    
    # Install Docker (for containerized development)
    install_docker || print_warning "Docker installation had issues, continuing..."
    
    # Install build tools
    install_build_tools || print_warning "Build tools installation had issues, continuing..."
    
    # Install LSP servers for IDE functionality
    install_lsp_servers || print_warning "LSP servers installation had issues, continuing..."
    
    return 0
}

# Install Node Version Manager (nvm) and Node.js
install_nodejs() {
    print_title "Node Version Manager & Node.js Installation"
    
    # Target Node.js version
    local NODE_VERSION="20"  # Node.js 20.x LTS
    local NVM_VERSION="0.39.7"  # Latest stable nvm version
    
    # Remove any system-installed Node.js to avoid conflicts
    if dpkg -l | grep -q "^ii  nodejs "; then
        print_info "Removing system-installed Node.js to avoid conflicts with nvm..."
        execute \
            "sudo apt-get remove -qqy nodejs npm" \
            "Removing system Node.js"
        
        # Clean up old nodejs sources
        execute \
            "sudo rm -f /etc/apt/sources.list.d/nodesource.list*" \
            "Cleaning up NodeSource repository"
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
        print_success "nvm (already installed)"
        
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
        
        # Verify installation
        if command -v node >/dev/null 2>&1; then
            local node_version=$(node --version 2>/dev/null)
            local npm_version=$(npm --version 2>/dev/null)
            print_success "Node.js $node_version installed via nvm"
            print_success "npm $npm_version installed"
        else
            print_error "Failed to install Node.js via nvm"
            return 1
        fi
    else
        print_error "nvm installation failed"
        return 1
    fi
    
    # Install global packages
    install_nodejs_packages
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

# Install Node.js global packages
install_nodejs_packages() {
    print_info "Installing global npm packages..."
    
    # Common development tools (without sudo since nvm manages this)
    local npm_packages=(
        "yarn"           # Alternative package manager
        "pnpm"           # Fast, disk space efficient package manager
        "typescript"     # TypeScript compiler
        "ts-node"        # TypeScript execution
        "nodemon"        # Auto-restart on file changes
        "prettier"       # Code formatter
        "eslint"         # JavaScript linter
    )
    
    for package in "${npm_packages[@]}"; do
        if npm list -g "$package" &>/dev/null; then
            print_success "$package (already installed globally)"
        else
            execute \
                "npm install -g '$package'" \
                "Installing $package"
        fi
    done
}

# Install Java development tools
install_java() {
    print_title "Java Development Environment"
    
    # Install OpenJDK 17 (LTS)
    if ! check_command java; then
        execute \
            "sudo apt-get install -qqy openjdk-17-jdk" \
            "Installing OpenJDK 17"
    else
        local java_version=$(java --version 2>/dev/null | head -n1)
        print_success "Java already installed: $java_version"
    fi
    
    # Install Maven
    if ! check_command mvn; then
        execute \
            "sudo apt-get install -qqy maven" \
            "Installing Apache Maven"
    else
        print_success "Maven already installed"
    fi
    
    # Install Gradle
    if ! check_command gradle; then
        execute \
            "sudo apt-get install -qqy gradle" \
            "Installing Gradle"
    else
        print_success "Gradle already installed"
    fi
}

# Install Python development tools
install_python_dev() {
    print_title "Python Development Tools"
    
    # Python3 should already be installed, but ensure pip is available
    if ! check_command pip3; then
        execute \
            "sudo apt-get update -qq && sudo apt-get install -qqy python3-pip" \
            "Installing pip3" || {
                print_warning "Failed to install pip3, continuing..."
                return 0
            }
    else
        print_success "pip3 already installed"
    fi
    
    # Install Python development packages
    execute \
        "sudo apt-get install -qqy python3-dev python3-venv" \
        "Installing Python development packages" || {
            print_warning "Failed to install Python dev packages, continuing..."
        }
    
    # Install common Python tools (only if pip3 is available)
    if check_command pip3; then
        if ! pip3 show black >/dev/null 2>&1; then
            execute \
                "pip3 install --user --break-system-packages black 2>/dev/null || pip3 install --user black" \
                "Installing Black formatter" || {
                    print_warning "Failed to install Black formatter"
                }
        else
            print_success "Black formatter already installed"
        fi
        
        if ! pip3 show pylint >/dev/null 2>&1; then
            execute \
                "pip3 install --user --break-system-packages pylint 2>/dev/null || pip3 install --user pylint" \
                "Installing Pylint" || {
                    print_warning "Failed to install Pylint"
                }
        else
            print_success "Pylint already installed"
        fi
    else
        print_warning "pip3 not available, skipping Python tool installation"
    fi
    
    return 0
}

# Install Docker
install_docker() {
    print_title "Docker Installation"
    
    if check_command docker; then
        print_success "Docker already installed"
        local docker_version=$(docker --version 2>/dev/null)
        print_info "Version: $docker_version"
    else
        # Install Docker dependencies
        execute \
            "sudo apt-get install -qqy apt-transport-https ca-certificates curl gnupg lsb-release" \
            "Installing Docker dependencies"
        
        # Remove any existing Docker GPG key file first to avoid any prompts
        sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null || true
        
        # Add Docker's official GPG key (using --batch and --yes to avoid all prompts)
        execute \
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" \
            "Adding Docker GPG key"
        
        # Set up the stable repository
        execute \
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" \
            "Adding Docker repository"
        
        execute \
            "sudo apt-get update -qq" \
            "Updating package lists"
        
        # Install Docker Engine
        execute \
            "sudo apt-get install -qqy docker-ce docker-ce-cli containerd.io docker-compose-plugin" \
            "Installing Docker Engine and Docker Compose"
        
        # Add current user to docker group
        if ! groups $USER | grep -q docker; then
            execute \
                "sudo usermod -aG docker $USER" \
                "Adding user to docker group"
            print_warning "You need to log out and back in for docker group changes to take effect"
        fi
    fi
}

# Install build tools
install_build_tools() {
    print_title "Build Tools"
    
    local build_tools=(
        "make"
        "cmake"
        "autoconf"
        "automake"
        "pkg-config"
        "libssl-dev"
        "libffi-dev"
    )
    
    for tool in "${build_tools[@]}"; do
        if ! dpkg -l | grep -q "^ii  $tool "; then
            execute \
                "sudo apt-get install -qqy $tool" \
                "Installing $tool"
        else
            print_success "$tool already installed"
        fi
    done
}

# Install LSP servers for Neovim IDE functionality
install_lsp_servers() {
    print_title "Language Server Protocol (LSP) Servers"
    
    # Continue even if individual servers fail
    set +e
    
    # Source nvm for this function
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # JavaScript/TypeScript LSP (no sudo needed with nvm)
    if check_command npm; then
        # TypeScript Language Server
        if ! npm list -g typescript-language-server 2>/dev/null | grep -q typescript-language-server; then
            execute \
                "npm install -g typescript typescript-language-server" \
                "Installing TypeScript Language Server"
        else
            print_success "TypeScript Language Server already installed"
        fi
        
        # ESLint Language Server
        if ! npm list -g vscode-langservers-extracted 2>/dev/null | grep -q vscode-langservers-extracted; then
            execute \
                "npm install -g vscode-langservers-extracted" \
                "Installing ESLint/HTML/CSS/JSON Language Servers"
        else
            print_success "VSCode Language Servers already installed"
        fi
        
        # Tailwind CSS Language Server
        if ! npm list -g @tailwindcss/language-server 2>/dev/null | grep -q @tailwindcss/language-server; then
            execute \
                "npm install -g @tailwindcss/language-server" \
                "Installing Tailwind CSS Language Server"
        else
            print_success "Tailwind CSS Language Server already installed"
        fi
        
        # Prettier formatter (already installed in nodejs packages)
        if ! npm list -g prettier 2>/dev/null | grep -q prettier; then
            execute \
                "npm install -g prettier" \
                "Installing Prettier formatter"
        else
            print_success "Prettier already installed"
        fi
        
        # JavaScript Debug Adapter for DAP
        # Note: vscode-js-debug needs to be built from source or installed via Mason in Neovim
        # It's not available as a simple npm package
        # Users should install it through Mason.nvim or build manually:
        # git clone https://github.com/microsoft/vscode-js-debug
        # cd vscode-js-debug && npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out
        print_info "JavaScript Debug Adapter should be installed via Mason.nvim in Neovim"
    fi
    
    # Python LSP
    if check_command pip3; then
        # Try to install pipx first as a better alternative
        if ! check_command pipx; then
            execute \
                "sudo apt-get install -qqy pipx" \
                "Installing pipx for Python packages" || true
            # Ensure pipx path is in PATH (suppress output as it's informational)
            pipx ensurepath >/dev/null 2>&1 || true
        fi
        
        if ! pip3 show python-lsp-server >/dev/null 2>&1 && ! pipx list 2>/dev/null | grep -q python-lsp-server; then
            execute \
                "pip3 install --user --break-system-packages 'python-lsp-server[all]' 2>/dev/null || \
                 pip3 install --user 'python-lsp-server[all]' 2>/dev/null || \
                 pipx install 'python-lsp-server[all]' 2>/dev/null || \
                 true" \
                "Installing Python Language Server" || {
                    print_warning "Could not install Python Language Server"
                }
        else
            print_success "Python Language Server already installed"
        fi
        
        # Python Debug Adapter
        if ! pip3 show debugpy >/dev/null 2>&1 && ! pipx list 2>/dev/null | grep -q debugpy; then
            execute \
                "pip3 install --user --break-system-packages debugpy 2>/dev/null || \
                 pip3 install --user debugpy 2>/dev/null || \
                 pipx install debugpy 2>/dev/null || \
                 true" \
                "Installing Python Debug Adapter" || {
                    print_warning "Could not install Python Debug Adapter"
                }
        else
            print_success "Python Debug Adapter already installed"
        fi
    fi
    
    # Bash Language Server
    if check_command npm; then
        if ! npm list -g bash-language-server 2>/dev/null | grep -q bash-language-server; then
            execute \
                "npm install -g bash-language-server" \
                "Installing Bash Language Server"
        else
            print_success "Bash Language Server already installed"
        fi
    fi
    
    # YAML Language Server
    if check_command npm; then
        if ! npm list -g yaml-language-server 2>/dev/null | grep -q yaml-language-server; then
            execute \
                "npm install -g yaml-language-server" \
                "Installing YAML Language Server"
        else
            print_success "YAML Language Server already installed"
        fi
    fi
    
    # Lua Language Server (for Neovim config development)
    install_lua_language_server
    
    # Return success even if some servers failed
    return 0
}

# Install Lua Language Server
install_lua_language_server() {
    print_info "Checking Lua Language Server"
    
    if [ ! -f "/usr/local/bin/lua-language-server" ]; then
        # Download and install lua-language-server
        local LUA_LS_VERSION="3.7.4"
        local TEMP_DIR=$(mktemp -d)
        
        execute \
            "cd $TEMP_DIR && \
             curl -Lo lua-language-server.tar.gz \"https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz\" && \
             tar xzf lua-language-server.tar.gz && \
             sudo mkdir -p /usr/local/lib/lua-language-server && \
             sudo cp -r * /usr/local/lib/lua-language-server/ && \
             sudo ln -sf /usr/local/lib/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server && \
             cd - && rm -rf $TEMP_DIR" \
            "Installing Lua Language Server"
    else
        print_success "Lua Language Server already installed"
    fi
}

# Configure terminal and console
configure_terminal() {
    print_title "Terminal Configuration"
    
    # Set default editor
    if ! grep -q "EDITOR=" "$HOME/.bashrc" 2>/dev/null; then
        execute \
            "echo 'export EDITOR=vim' >> '$HOME/.bashrc'" \
            "Setting default editor to vim"
    else
        print_success "Default editor (already set)"
    fi
    
    # Enable color prompt if not already enabled
    if [ -f "$HOME/.bashrc" ]; then
        execute \
            "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' '$HOME/.bashrc'" \
            "Enabling color prompt"
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
        # Try with sudo first (for systems that require it)
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
        print_info "Please manually update your shell in /etc/passwd"
    fi
    
    return 0
}

# Main function
main() {
    # Step 1: System verification and preparation
    verify_ubuntu
    ask_for_sudo
    update_package_lists
    
    # Step 2: Core system tools
    install_git
    install_essential_tools
    initialize_git_repo
    configure_system
    
    # Step 3: Shell and terminal setup (foundation)
    configure_terminal
    configure_shell
    
    # Step 4: Text-based development environment (primary)
    install_text_based_dev_environment
    
    # Step 5: Programming languages and tools
    install_programming_tools
    
    # Step 6: Set ZSH as default shell if installed
    set_default_shell
    
    # Note: Visual development tools not applicable for Ubuntu Server
    # (Those would be in the macOS setup script)
    
    print_title "Setup Complete!"
    print_success "Ubuntu Server configured successfully"
    
    # Check if shell change requires re-login
    if [ "$SHELL" != "$(which zsh 2>/dev/null)" ] && check_command zsh; then
        print_warning "Shell has been changed to ZSH. Please log out and back in for the change to take effect."
    else
        print_info "Some changes may require a new terminal session to take effect"
    fi
    
    return 0
}

# Execute main function when script is run directly
main "$@"