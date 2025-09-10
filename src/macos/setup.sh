#!/bin/bash

# macOS-specific setup script for dotfiles
# This script configures a macOS system for full-stack development with IDE environment
# Includes full IDE setup with Neovim, ZSH, and all development tools

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
        
        # Execute command silently
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
    # Ask for the administrator password upfront
    print_info "Administrator privileges will be required..."
    
    # Check if we have sudo access
    if ! sudo -v; then
        print_error "Failed to obtain administrator privileges"
        exit 1
    fi
    
    # Keep sudo alive until the script finishes
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
    
    print_success "Administrator privileges obtained"
}

# Verify we're running on macOS
verify_macos() {
    # Check if we're on macOS
    if [ "$(uname -s)" != "Darwin" ]; then
        print_error "This script is for macOS only"
        exit 1
    fi
    
    # Get macOS version
    local macos_version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    print_info "macOS version: $macos_version"
    
    # Check architecture
    local arch=$(uname -m)
    if [ "$arch" = "arm64" ]; then
        print_info "Apple Silicon (M1/M2/M3) detected"
    else
        print_info "Intel processor detected"
    fi
    
    print_success "macOS environment verified"
}

# Check and install Xcode Command Line Tools
install_xcode_tools() {
    print_title "Xcode Command Line Tools"
    
    # Check if already installed
    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools already installed"
        local xcode_path=$(xcode-select -p)
        print_info "Installation path: $xcode_path"
        return 0
    fi
    
    print_info "Installing Xcode Command Line Tools..."
    print_info "This will open a dialog window. Please click 'Install' when prompted."
    
    # Trigger the installation
    xcode-select --install &>/dev/null || true
    
    # Wait for installation to complete
    print_info "Waiting for Xcode Command Line Tools installation to complete..."
    print_info "This may take 10-20 minutes depending on your internet connection"
    
    local wait_time=0
    while ! xcode-select -p &>/dev/null; do
        sleep 10
        wait_time=$((wait_time + 10))
        if [ $((wait_time % 60)) -eq 0 ]; then
            print_info "Still installing... ($((wait_time / 60)) minutes elapsed)"
        fi
    done
    
    print_success "Xcode Command Line Tools installed successfully"
    
    # Accept license if needed
    execute "sudo xcodebuild -license accept 2>/dev/null || true" \
            "Accepting Xcode license"
}

# Install Homebrew package manager
install_homebrew() {
    print_title "Homebrew Package Manager"
    
    if check_command brew; then
        print_success "Homebrew already installed"
        local brew_version=$(brew --version 2>/dev/null | head -n1)
        print_info "$brew_version"
        execute "brew update" "Updating Homebrew"
        return 0
    fi
    
    print_info "Installing Homebrew..."
    
    # Download and run the official Homebrew installer non-interactively
    # Use printf to simulate ENTER keypress for the confirmation prompt
    if ! printf "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &> /dev/null; then
        print_error "Homebrew installation failed"
        print_info "Please install Homebrew manually from https://brew.sh"
        exit 1
    fi
    
    print_success "Homebrew installed"
    
    # Determine Homebrew location based on architecture and add to current session
    local brew_path=""
    if [ -f "/opt/homebrew/bin/brew" ]; then
        # Apple Silicon
        brew_path="/opt/homebrew/bin/brew"
        print_info "Configuring Homebrew for Apple Silicon..."
        eval "$($brew_path shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        # Intel Mac
        brew_path="/usr/local/bin/brew"
        print_info "Configuring Homebrew for Intel Mac..."
        eval "$($brew_path shellenv)"
    else
        print_error "Failed to find Homebrew installation"
        print_info "Please check if Homebrew was installed correctly"
        exit 1
    fi
    
    # Add Homebrew to shell profiles for future sessions
    for profile_file in "$HOME/.zprofile" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ ! -f "$profile_file" ] && [ "$profile_file" = "$HOME/.zprofile" ]; then
            # Create .zprofile if it doesn't exist (it's the main one for macOS)
            touch "$profile_file"
        fi
        
        if [ -f "$profile_file" ]; then
            if ! grep -q "homebrew" "$profile_file" 2>/dev/null; then
                echo "" >> "$profile_file"
                echo "# Homebrew" >> "$profile_file"
                echo "eval \"\$($brew_path shellenv)\"" >> "$profile_file"
                print_success "Added Homebrew to $(basename $profile_file)"
            fi
        fi
    done
    
    # Verify installation in current session
    if check_command brew; then
        print_success "Homebrew installed successfully"
        local brew_version=$(brew --version 2>/dev/null | head -n1)
        print_info "$brew_version"
    else
        print_error "Homebrew was installed but is not available in current session"
        print_info "Please restart your terminal or run: eval \"\$($brew_path shellenv)\""
        exit 1
    fi
}

# Install Git via Homebrew
install_git() {
    print_title "Git & Build Essentials"
    
    # Ensure brew is available
    if ! check_command brew; then
        print_error "Homebrew is not available. Cannot install Git."
        return 1
    fi
    
    # Check if git is already installed via Homebrew
    if brew list git &>/dev/null; then
        print_success "Git (already installed via Homebrew)"
        execute "brew upgrade git 2>/dev/null || true" "Updating Git"
    else
        execute "brew install git" "Git"
    fi
    
    # Install other version control tools
    local vcs_tools=(
        "git-lfs"      # Large file storage
        "gh"           # GitHub CLI
    )
    
    for tool in "${vcs_tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_success "$tool (already installed)"
        else
            execute "brew install '$tool'" "$tool"
        fi
    done
}

# Install essential command-line tools
install_essential_tools() {
    print_title "Essential Tools"
    
    # Ensure brew is available
    if ! check_command brew; then
        print_error "Homebrew is not available. Cannot install essential tools."
        return 1
    fi
    
    # Match Ubuntu's essential tools list
    local tools=(
        "tree"         # Directory listing
        "htop"         # Process viewer
        "ncdu"         # Disk usage analyzer
        "tmux"         # Terminal multiplexer
        "screen"       # Terminal multiplexer alternative
        "vim"          # Text editor
        "nano"         # Simple text editor (comes with macOS but ensure latest)
        "jq"           # JSON processor
        "unzip"        # Archive extraction (comes with macOS but ensure latest)
        "zip"          # Archive creation (comes with macOS but ensure latest)
        "wget"         # Alternative to curl
        "fzf"          # Fuzzy finder for command history and files
    )
    
    # macOS-specific replacements/additions that are truly essential
    # net-tools equivalent functionality is built into macOS
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_success "$tool (already installed)"
        else
            execute "brew install '$tool'" "$tool"
            
            # Special post-installation for fzf
            if [ "$tool" = "fzf" ] && check_command fzf; then
                # Install fzf key bindings and fuzzy completion
                execute "$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish" \
                        "Configure fzf key bindings and completion"
                
                # Add fzf configuration to .zshrc if not already present
                if [ -f "$HOME/.zshrc" ] && ! grep -q "FZF_BASE" "$HOME/.zshrc"; then
                    echo "" >> "$HOME/.zshrc"
                    echo "# FZF configuration" >> "$HOME/.zshrc"
                    echo "export FZF_BASE=\"$(brew --prefix)/opt/fzf\"" >> "$HOME/.zshrc"
                    echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> "$HOME/.zshrc"
                    print_success "Added fzf configuration to .zshrc"
                fi
            fi
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
    
    # Install popular third-party plugins
    install_oh_my_zsh_plugins
    
    # Install Powerline fonts
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
    
    # Install via Homebrew cask
    execute \
        "brew tap homebrew/cask-fonts 2>/dev/null || true" \
        "Adding fonts tap"
    
    # Install popular programming fonts with Powerline support
    local fonts=(
        "font-meslo-lg-nerd-font"
        "font-hack-nerd-font"
        "font-fira-code-nerd-font"
    )
    
    for font in "${fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            print_success "$font already installed"
        else
            execute \
                "brew install --cask '$font' 2>/dev/null || true" \
                "Installing $font"
        fi
    done
    
    print_info "Configure Terminal.app to use one of the installed Nerd Fonts"
    print_info "Go to Terminal > Preferences > Profiles > Text > Font"
}

# Configure shell environment (foundation for text-based development)
configure_shell() {
    print_title "Shell Environment Configuration"
    
    # ZSH is default on modern macOS, but ensure it's set as default
    local current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
    local zsh_path="/bin/zsh"
    
    if [ "$current_shell" != "$zsh_path" ]; then
        execute \
            "chsh -s '$zsh_path'" \
            "Setting ZSH as default shell"
    else
        print_success "ZSH is already the default shell"
    fi
    
    # Configure ZSH with Oh My Zsh theme and plugins
    if [ -f "$HOME/.zshrc" ]; then
        # Set theme
        if ! grep -q "^ZSH_THEME=" "$HOME/.zshrc"; then
            echo 'ZSH_THEME="agnoster"' >> "$HOME/.zshrc"
        else
            sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$HOME/.zshrc"
        fi
        print_success "Set Oh My Zsh theme to agnoster"
        
        # Configure plugins
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            # Build plugin list based on what's installed
            local plugin_list="git brew tmux zsh-autosuggestions zsh-syntax-highlighting zsh-completions"
            
            # Add conditional plugins based on what's available
            if check_command docker; then
                plugin_list="$plugin_list docker docker-compose"
            fi
            if check_command node; then
                plugin_list="$plugin_list node npm"
            fi
            if [ -d "$HOME/.nvm" ]; then
                plugin_list="$plugin_list nvm"
            fi
            if check_command fzf; then
                plugin_list="$plugin_list fzf"
            fi
            
            # Update plugins line
            sed -i '' "s/^plugins=.*/plugins=($plugin_list)/" "$HOME/.zshrc"
            print_success "Configured Oh My Zsh plugins"
        fi
    fi
    
    print_success "Shell environment configured with Oh My Zsh"
}

# Install Neovim
install_neovim() {
    print_title "Neovim Installation"
    
    # Check if Neovim is already installed
    if brew list neovim &>/dev/null; then
        print_success "Neovim already installed"
        execute "brew upgrade neovim 2>/dev/null || true" "Checking for Neovim updates"
        local nvim_version=$(nvim --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        print_info "Neovim version: $nvim_version"
    else
        execute "brew install neovim" "Installing Neovim"
        
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
    
    # Node support
    if check_command npm; then
        if ! npm list -g neovim 2>/dev/null | grep -q neovim; then
            execute \
                "npm install -g neovim" \
                "Installing Node.js Neovim support"
        else
            print_success "Node.js Neovim support already installed"
        fi
    fi
    
    # Install lazygit for git integration
    if ! brew list lazygit &>/dev/null; then
        execute "brew install lazygit" "Installing lazygit"
    else
        print_success "lazygit already installed"
    fi
    
    # Install language servers and tools
    local dev_tools=(
        "lua-language-server"    # Lua LSP
        "shellcheck"             # Shell script linting
        "shfmt"                  # Shell script formatting
    )
    
    for tool in "${dev_tools[@]}"; do
        if ! brew list "$tool" &>/dev/null; then
            execute "brew install '$tool'" "Installing $tool"
        else
            print_success "$tool already installed"
        fi
    done
}

# Configure Neovim
configure_neovim() {
    print_title "Neovim Configuration"
    
    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_source_dir="$SCRIPT_DIR/../ubuntu/configs/nvim-ide"
    
    # Create config directory if it doesn't exist
    if [ ! -d "$nvim_config_dir" ]; then
        execute \
            "mkdir -p '$nvim_config_dir'" \
            "Creating Neovim config directory"
    fi
    
    # Check if IDE configuration exists in Ubuntu configs
    if [ -d "$nvim_source_dir" ]; then
        # Backup existing configuration if present
        if [ -d "$nvim_config_dir" ] && [ "$(ls -A $nvim_config_dir 2>/dev/null)" ]; then
            execute \
                "mv '$nvim_config_dir' '$nvim_config_dir.backup.$(date +%Y%m%d_%H%M%S)'" \
                "Backing up existing Neovim configuration"
            execute \
                "mkdir -p '$nvim_config_dir'" \
                "Creating new Neovim config directory"
        fi
        
        execute \
            "cp -r '$nvim_source_dir'/* '$nvim_config_dir/'" \
            "Installing Neovim IDE configuration"
        
        print_success "Full IDE Neovim configuration installed"
        print_info "Neovim will install plugins on first launch"
        print_info "LSP servers for JavaScript, TypeScript, and Java are configured"
    else
        print_warning "Neovim IDE configuration not found, using basic setup"
    fi
    
    # Add vi and vim aliases to use Neovim
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "alias vi=nvim" "$HOME/.zshrc" 2>/dev/null; then
            cat >> "$HOME/.zshrc" << 'EOF'

# Neovim aliases
alias vi='nvim'
alias vim='nvim'
export EDITOR=nvim
EOF
            print_success "Added Neovim aliases to .zshrc"
        fi
    fi
}

# Install tmux
install_tmux() {
    print_title "Tmux Installation"
    
    if brew list tmux &>/dev/null; then
        print_success "Tmux already installed"
        execute \
            "brew upgrade tmux 2>/dev/null || true" \
            "Checking for tmux updates"
    else
        execute \
            "brew install tmux" \
            "Installing tmux"
    fi
    
    # Install tmux plugin manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        execute \
            "git clone https://github.com/tmux-plugins/tpm '$HOME/.tmux/plugins/tpm'" \
            "Installing tmux plugin manager"
    else
        print_success "Tmux plugin manager already installed"
    fi
    
    # Copy tmux configuration if available
    local tmux_config="$SCRIPT_DIR/../ubuntu/configs/tmux/.tmux.conf"
    if [ -f "$tmux_config" ]; then
        execute \
            "cp '$tmux_config' '$HOME/.tmux.conf'" \
            "Installing tmux configuration"
    fi
}

# Install text-based development environment (primary focus)
install_text_based_dev_environment() {
    print_title "Text-Based Development Environment"
    
    # Install Neovim as primary IDE
    install_neovim
    
    # Install tmux for terminal multiplexing
    install_tmux
    
    print_success "Text-based development environment installed"
}

# Install programming languages and tools
install_programming_tools() {
    print_title "Programming Languages & Tools"
    
    # Install Node.js and npm
    install_nodejs || print_warning "Node.js installation had issues, continuing..."
    
    # Install Java development tools
    install_java || print_warning "Java installation had issues, continuing..."
    
    
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
        
        # Source nvm and install Node
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
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
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
    
    # Add to .zshrc if present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Node Version Manager (nvm)" >> "$HOME/.zshrc"
            echo "$nvm_init" >> "$HOME/.zshrc"
            print_success "Added nvm to .zshrc"
        fi
    fi
    
    # Add to .bash_profile if present
    if [ -f "$HOME/.bash_profile" ]; then
        if ! grep -q "NVM_DIR" "$HOME/.bash_profile"; then
            echo "" >> "$HOME/.bash_profile"
            echo "# Node Version Manager (nvm)" >> "$HOME/.bash_profile"
            echo "$nvm_init" >> "$HOME/.bash_profile"
            print_success "Added nvm to .bash_profile"
        fi
    fi
}

# Install Node.js global packages
install_nodejs_packages() {
    print_info "Installing global npm packages..."
    
    # Common development tools
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
    if ! brew list openjdk@17 &>/dev/null; then
        execute \
            "brew install openjdk@17" \
            "Installing OpenJDK 17"
    else
        print_success "OpenJDK 17 already installed"
    fi
    
    # Always ensure symlinks are created (they might be missing even if brew package is installed)
    # This is required for java_home to detect the JDK
    local java_source="$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk"
    local java_target="/Library/Java/JavaVirtualMachines/openjdk-17.jdk"
    
    if [ -d "$java_source" ]; then
        if [ ! -e "$java_target" ] || [ ! -L "$java_target" ]; then
            execute \
                "sudo ln -sfn '$java_source' '$java_target'" \
                "Creating Java symlinks for system detection"
        else
            print_success "Java symlinks already configured"
        fi
        
        # Also ensure the JDK is properly registered with java_home
        # This helps java_home find it immediately without needing a new shell
        if ! /usr/libexec/java_home -v 17 &>/dev/null; then
            print_warning "Java 17 installed but not detected by java_home yet"
            print_info "This will be resolved after restarting your terminal"
        fi
    else
        print_warning "OpenJDK 17 installation directory not found at expected location"
    fi
    
    # Set JAVA_HOME (OpenJDK 17 was just installed above)
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "JAVA_HOME" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Java" >> "$HOME/.zshrc"
            echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home")' >> "$HOME/.zshrc"
            echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.zshrc"
            print_success "Set JAVA_HOME in .zshrc"
        fi
    fi
    
    # Install Maven
    if ! brew list maven &>/dev/null; then
        execute \
            "brew install maven" \
            "Installing Apache Maven"
    else
        print_success "Maven already installed"
    fi
    
    # Install Gradle
    if ! brew list gradle &>/dev/null; then
        execute \
            "brew install gradle" \
            "Installing Gradle"
    else
        print_success "Gradle already installed"
    fi
}

# Install Docker
install_docker() {
    print_title "Docker Installation"
    
    # Check if Docker Desktop is already installed
    if [ -d "/Applications/Docker.app" ]; then
        print_success "Docker Desktop already installed"
        return 0
    fi
    
    # Install Docker Desktop via Homebrew Cask
    execute \
        "brew install --cask docker" \
        "Installing Docker Desktop"
    
    print_info "Docker Desktop installed"
    print_info "Please launch Docker Desktop from Applications to complete setup"
    print_info "You may need to provide your password to install helper tools"
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
        "libtool"
    )
    
    for tool in "${build_tools[@]}"; do
        if ! brew list "$tool" &>/dev/null; then
            execute \
                "brew install '$tool'" \
                "Installing $tool"
        else
            print_success "$tool already installed"
        fi
    done
}

# Install LSP servers for Neovim IDE functionality
install_lsp_servers() {
    print_title "Language Server Protocol (LSP) Servers"
    
    # Source nvm for this function
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # JavaScript/TypeScript LSP
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
        
        # Bash Language Server
        if ! npm list -g bash-language-server 2>/dev/null | grep -q bash-language-server; then
            execute \
                "npm install -g bash-language-server" \
                "Installing Bash Language Server"
        else
            print_success "Bash Language Server already installed"
        fi
        
        # YAML Language Server
        if ! npm list -g yaml-language-server 2>/dev/null | grep -q yaml-language-server; then
            execute \
                "npm install -g yaml-language-server" \
                "Installing YAML Language Server"
        else
            print_success "YAML Language Server already installed"
        fi
    fi
    
    print_info "Note: Java LSP (jdtls) will be installed via Mason.nvim in Neovim"
    print_info "Additional LSP servers can be installed via Mason.nvim (:Mason in Neovim)"
    
    return 0
}

# Install VS Code (supplementary GUI editor)
install_vscode() {
    print_title "Visual Studio Code (Supplementary)"
    
    # Check if VS Code is already installed
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        print_success "VS Code already installed"
        return 0
    fi
    
    # Install via Homebrew Cask
    execute \
        "brew install --cask visual-studio-code" \
        "Installing Visual Studio Code"
    
    # Install code command in PATH
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        # The 'code' command should be automatically available
        print_success "VS Code installed"
        print_info "VS Code available as supplementary GUI editor"
        print_info "Primary development should use Neovim in terminal"
    fi
}

# Configure Terminal.app
configure_terminal() {
    print_title "Terminal Configuration"
    
    # Apply Terminal.app preferences using defaults
    execute "defaults write com.apple.terminal FocusFollowsMouse -string true" \
            "Enable focus follows mouse"
    
    execute "defaults write com.apple.terminal SecureKeyboardEntry -bool true" \
            "Enable secure keyboard entry"
    
    execute "defaults write com.apple.Terminal ShowLineMarks -int 0" \
            "Hide line marks"
    
    execute "defaults write com.apple.terminal StringEncodings -array 4" \
            "Set UTF-8 encoding"
    
    # Set window size defaults
    execute "defaults write com.apple.terminal 'Window Settings'.Basic.columnCount -int 120" \
            "Set default window width to 120 columns"
    
    execute "defaults write com.apple.terminal 'Window Settings'.Basic.rowCount -int 40" \
            "Set default window height to 40 rows"
    
    # Apply custom theme (following alrra's exact approach)
    if [ -f "$SCRIPT_DIR/terminal-themes/Developer Dark.terminal" ] && [ -f "$SCRIPT_DIR/scripts/set_terminal_theme.applescript" ]; then
        # Copy the AppleScript to the themes directory (alrra runs it from same dir as theme)
        cp "$SCRIPT_DIR/scripts/set_terminal_theme.applescript" "$SCRIPT_DIR/terminal-themes/" 2>/dev/null
        chmod +x "$SCRIPT_DIR/terminal-themes/set_terminal_theme.applescript"
        
        # Change to the themes directory and run the script
        (
            cd "$SCRIPT_DIR/terminal-themes"
            execute "./set_terminal_theme.applescript" \
                    "Apply Developer Dark theme"
        )
        
        # Clean up the temporary AppleScript copy
        rm -f "$SCRIPT_DIR/terminal-themes/set_terminal_theme.applescript" 2>/dev/null
    else
        print_warning "Terminal theme script not found, creating fallback configuration"
        
        # Fallback: At least set the font using defaults
        # This sets the font for the Basic profile
        execute "defaults write com.apple.terminal 'Window Settings'.Basic.Font -data $(echo 'YnBsaXN0MDDUAQIDBAUGGBlYJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3ASAAGGoKQHCBESVSRudWxs1AkKCwwNDg8QVk5TU2l6ZVhOU2ZGbGFnc1ZOU05hbWVWJGNsYXNzI0AuAAAAAAAAEBCAAoADXxAXTWVzbG9MR1NOZU9yZEZvbnQtUmVndWxhctITFBUWWiRjbGFzc25hbWVYJGNsYXNzZXNWTlNGb250ohUXWE5TT2JqZWN0XxAPTlNLZXllZEFyY2hpdmVy0RobVHJvb3SAAQgRGiMtMjc8QktSW2JpcnR2eJWan6attsfZ3OMAAAAAAAAABAAAAAAAAAAAHAAAAAAAAAAAAAAAAAAAA5Q==' | base64 -D)" \
                "Set MesloLGS Nerd Font as default font" 2>/dev/null || true
    fi
    
    # Enable Touch ID for sudo (bonus feature from alrra example)
    if ! grep -q "pam_tid.so" "/etc/pam.d/sudo" 2>/dev/null; then
        execute "sudo sh -c 'echo \"auth sufficient pam_tid.so\" >> /etc/pam.d/sudo'" \
                "Enable Touch ID for sudo authentication"
    fi
    
    print_success "Terminal.app configured with Developer Dark theme and Nerd Font"
    print_info "Note: You may need to restart Terminal.app for all changes to take effect"
}

# Main function
main() {
    print_info "Starting macOS setup..."
    print_info "This will configure a complete development environment"
    
    # Step 1: System verification and preparation
    verify_macos
    ask_for_sudo  # Get sudo access upfront before any installations
    install_xcode_tools
    install_homebrew
    
    # Step 2: Core system tools
    install_git
    install_essential_tools
    initialize_git_repo
    
    # Step 3: Shell and terminal setup (foundation)
    install_oh_my_zsh
    configure_shell
    
    # Step 4: Text-based development environment (primary)
    install_text_based_dev_environment
    
    # Step 5: Programming languages and tools
    install_programming_tools
    
    # Step 6: Visual development environment (macOS bonus)
    install_vscode
    
    # Step 7: Terminal configuration
    configure_terminal
    
    print_title "Setup Complete!"
    print_success "macOS configured successfully with full IDE environment"
    
    print_info ""
    print_info "Next steps:"
    print_info "1. Restart your terminal or run: source ~/.zshrc"
    print_info "2. Launch Neovim with 'nvim' to install IDE plugins"
    print_info "3. Configure Terminal.app to use a Nerd Font (see instructions above)"
    print_info ""
    print_info "IDE Keybindings (Space as leader key):"
    print_info "  Space e    - Toggle file explorer"
    print_info "  Space ff   - Find files"
    print_info "  Space fg   - Find text in files (grep)"
    print_info "  Space t    - Toggle terminal"
    print_info ""
    print_info "Development tools installed:"
    print_info "  - Neovim (primary IDE)"
    print_info "  - Node.js v20 LTS (via nvm)"
    print_info "  - Java 17 LTS (OpenJDK)"
    print_info "  - Python 3.12"
    print_info "  - Docker Desktop"
    print_info "  - VS Code (supplementary GUI editor)"
    print_info ""
    print_info "Some changes may require a new terminal session to take effect"
    
    return 0
}

# Execute main function when script is run directly
main "$@"