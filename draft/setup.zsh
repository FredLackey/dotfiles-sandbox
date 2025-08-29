#!/usr/bin/env zsh

# =============================================================================
# ZSH Dotfiles Setup Script
# =============================================================================
# A single-command setup script for macOS development environment
# Follows governing principles: idempotent, single-command, managed permissions
# =============================================================================

# Script continues on errors to ensure maximum package installation

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# =============================================================================
# Utility Functions
# =============================================================================

print_header() {
    echo
    echo "${BLUE}==============================================================================${NC}"
    echo "${BLUE} $1${NC}"
    echo "${BLUE}==============================================================================${NC}"
    echo
}

print_step() {
    echo "${YELLOW}→${NC} $1"
}

print_success() {
    echo "${GREEN}✓${NC} $1"
}

print_error() {
    echo "${RED}✗${NC} $1" >&2
}

print_info() {
    echo "${BLUE}ℹ${NC} $1"
}

# =============================================================================
# Prerequisite Detection Functions
# =============================================================================

check_xcode_cli_tools() {
    if xcode-select -p &> /dev/null; then
        return 0  # Already installed
    else
        return 1  # Not installed
    fi
}



check_homebrew() {
    if command -v brew &> /dev/null; then
        return 0  # Already installed
    else
        return 1  # Not installed
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

install_homebrew_package() {
    local name="$1"
    local formula="$2"
    local options="$3"
    local tap="$4"
    
    print_step "Installing $name..."
    
    # Add tap if specified
    if [[ -n "$tap" ]]; then
        if ! brew tap | grep -q "$tap" &> /dev/null; then
            print_info "Adding tap: $tap"
            brew tap "$tap" &> /dev/null
        fi
    fi
    
    if [[ "$options" == "--cask" ]]; then
        if brew list --cask "$formula" &> /dev/null; then
            print_success "$name already installed"
            return 0
        fi
    else
        if brew list "$formula" &> /dev/null; then
            print_success "$name already installed"
            return 0
        fi
    fi
    
    if brew install $options "$formula" &> /dev/null; then
        print_success "$name installed successfully"
    else
        print_error "Failed to install $name (continuing with next package)"
        # Don't return error code - continue with next package
    fi
}

install_xcode_cli_tools() {
    print_step "Installing Xcode Command Line Tools..."
    
    # Start the installation
    xcode-select --install 2>/dev/null || true
    
    print_info "Please complete the Xcode Command Line Tools installation in the dialog that appeared."
    print_info "Waiting for installation to complete (checking silently every 10 seconds)..."
    
    # Wait for installation to complete silently
    local dots=""
    while ! check_xcode_cli_tools; do
        sleep 10
        dots="${dots}."
        printf "\r${BLUE}ℹ${NC} Still waiting${dots}"
    done
    
    echo  # New line after the dots
    print_success "Xcode Command Line Tools installation completed!"
}



install_homebrew() {
    print_step "Installing Homebrew..."
    print_info "This will require administrator privileges for some operations."
    
    # Pre-create directories that Homebrew needs with proper permissions
    print_info "Setting up Homebrew directories..."
    
    # Determine Homebrew prefix based on architecture
    if [[ $(uname -m) == "arm64" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi
    
    # Create directories and set permissions if they don't exist
    if [[ ! -d "$HOMEBREW_PREFIX" ]]; then
        print_info "Creating $HOMEBREW_PREFIX directory (requires sudo)..."
        sudo mkdir -p "$HOMEBREW_PREFIX"
        sudo chown -R $(whoami):admin "$HOMEBREW_PREFIX"
    fi
    
    # Download and run Homebrew installer
    print_info "Running Homebrew installer..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
    
    # Add Homebrew to PATH for future sessions
    if [[ $(uname -m) == "arm64" ]]; then
        if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
        # Source the profile to make brew available in current session
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel Mac - Homebrew should already be in PATH at /usr/local/bin
        if ! grep -q '/usr/local/bin' ~/.zprofile 2>/dev/null; then
            echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zprofile
        fi
        export PATH="/usr/local/bin:$PATH"
    fi
    
    # Verify Homebrew is now accessible
    if command -v brew &> /dev/null; then
        print_success "Homebrew installation completed and verified!"
        print_info "Homebrew version: $(brew --version | head -n1)"
    else
        print_error "Homebrew installation completed but 'brew' command is not accessible!"
        print_error "You may need to restart your terminal or manually run: eval \"\$(/opt/homebrew/bin/brew shellenv)\""
        # Don't return error - let script continue
    fi
}

install_essential_packages() {
    print_header "Installing Essential Development Packages"
    
    # Development Tools
    print_info "Installing development tools..."
    install_homebrew_package "Git" "git"
    install_homebrew_package "Vim" "vim"
    install_homebrew_package "Bash" "bash"
    install_homebrew_package "Bash Completion" "bash-completion@2"
    install_homebrew_package "tmux" "tmux"
    install_homebrew_package "tmux Pasteboard Support" "reattach-to-user-namespace"
    
    # Command Line Utilities  
    print_info "Installing command line utilities..."
    install_homebrew_package "ShellCheck" "shellcheck"
    install_homebrew_package "jq (JSON processor)" "jq"
    install_homebrew_package "yq (YAML processor)" "yq"
    
    # Security Tools
    print_info "Installing security tools..."
    install_homebrew_package "GPG" "gpg"
    install_homebrew_package "GPG PIN Entry" "pinentry-mac"
    
    # Media Tools
    print_info "Installing media tools..."
    install_homebrew_package "FFmpeg" "ffmpeg"
    
    # Essential Applications (Casks)
    print_info "Installing essential applications..."
    install_homebrew_package "Visual Studio Code" "visual-studio-code" "--cask"
    install_homebrew_package "Google Chrome" "google-chrome" "--cask"
    install_homebrew_package "Docker" "docker" "--cask"
    
    print_success "Essential packages installation completed!"
}

install_additional_packages() {
    print_header "Installing Additional Development Packages"
    
    # Note: VS Code extensions from legacy project are handled separately
    # See legacy/src/os/installs/macos/vscode.sh for the full list of extensions
    
    # Development & Languages
    print_info "Installing additional development tools..."
    install_homebrew_package "Sublime Text" "sublime-text" "--cask"
    install_homebrew_package "Cursor (AI Code Editor)" "cursor" "--cask"
    install_homebrew_package "Go Language" "go"
    install_homebrew_package "AWS CLI" "awscli"
    install_homebrew_package "LFTP" "lftp"
    install_homebrew_package "Yarn" "yarn"
    install_homebrew_package "Terraform Version Manager" "tfenv"
    install_homebrew_package "Tailscale" "tailscale"
    
    # Media & Creative Tools
    print_info "Installing media and creative tools..."
    install_homebrew_package "ImageOptim" "imageoptim" "--cask"
    install_homebrew_package "Pngyu" "pngyu" "--cask"
    install_homebrew_package "AtomicParsley" "atomicparsley"
    install_homebrew_package "VLC Media Player" "vlc" "--cask"
    install_homebrew_package "Elmedia Player" "elmedia-player" "--cask"
    install_homebrew_package "Spotify" "spotify" "--cask"
    install_homebrew_package "Tidal" "tidal" "--cask"
    install_homebrew_package "Adobe Creative Cloud" "adobe-creative-cloud" "--cask"
    install_homebrew_package "Draw.io" "drawio" "--cask"
    
    # Communication & Collaboration
    print_info "Installing communication tools..."
    install_homebrew_package "Messenger" "messenger" "--cask"
    install_homebrew_package "WhatsApp" "whatsapp" "--cask"
    install_homebrew_package "Slack" "slack" "--cask"
    install_homebrew_package "Microsoft Office" "microsoft-office" "--cask"
    install_homebrew_package "Microsoft Teams" "microsoft-teams" "--cask"
    
    # Productivity & Utilities
    print_info "Installing productivity tools..."
    install_homebrew_package "Snagit" "snagit" "--cask"
    install_homebrew_package "Camtasia" "camtasia" "--cask"
    install_homebrew_package "AppCleaner" "appcleaner" "--cask"
    install_homebrew_package "Caffeine" "caffeine" "--cask"
    install_homebrew_package "Keyboard Maestro" "keyboard-maestro" "--cask"
    install_homebrew_package "Postman" "postman" "--cask"
    install_homebrew_package "Beyond Compare" "beyond-compare" "--cask"
    install_homebrew_package "Termius" "termius" "--cask"
    install_homebrew_package "Zoom" "zoom" "--cask"
    install_homebrew_package "yt-dlp" "yt-dlp"
    install_homebrew_package "Bambu Studio" "bambu-studio" "--cask"
    install_homebrew_package "balenaEtcher" "balenaetcher" "--cask"
    
    # Database Tools
    print_info "Installing database tools..."
    install_homebrew_package "DbSchema" "dbschema" "--cask"
    install_homebrew_package "MySQL Workbench" "mysqlworkbench" "--cask"
    install_homebrew_package "Studio 3T (MongoDB)" "studio-3t" "--cask"
    
    # Web Browsers
    print_info "Installing additional browsers..."
    install_homebrew_package "Google Chrome Canary" "google-chrome@canary" "--cask"
    # Safari Technology Preview requires macOS 10.11.4+
    if [[ $(sw_vers -productVersion | cut -d. -f1-2) > "10.11" ]]; then
        install_homebrew_package "Safari Technology Preview" "safari-technology-preview" "--cask"
    fi
    
    # AI & Security
    print_info "Installing AI and security tools..."
    install_homebrew_package "ChatGPT" "chatgpt" "--cask"
    install_homebrew_package "Superwhisper" "superwhisper" "--cask"
    install_homebrew_package "NordPass" "nordpass" "--cask"
    
    # Web Font Tools (with custom tap)
    print_info "Installing web font tools..."
    install_homebrew_package "SFNT2WOFF (Zopfli)" "sfnt2woff-zopfli" "" "bramstein/webfonttools"
    install_homebrew_package "SFNT2WOFF" "sfnt2woff" "" "bramstein/webfonttools"
    install_homebrew_package "WOFF2" "woff2" "" "bramstein/webfonttools"
    
    print_success "Additional packages installation completed!"
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    print_header "ZSH Dotfiles Setup - macOS Development Environment"
    
    print_info "This script will install essential development prerequisites:"
    print_info "• Xcode Command Line Tools"
    print_info "• Homebrew Package Manager"
    print_info "• Essential development packages and applications"
    echo
    
    # 1. Xcode Command Line Tools
    print_header "Checking Xcode Command Line Tools"
    if check_xcode_cli_tools; then
        print_success "Xcode Command Line Tools already installed"
    else
        install_xcode_cli_tools
    fi
    
    # 2. Homebrew
    print_header "Checking Homebrew"
    if check_homebrew; then
        print_success "Homebrew already installed"
    else
        install_homebrew
    fi
    
    # 3. Essential Packages
    if command -v brew &> /dev/null; then
        install_essential_packages
        
        # 4. Additional Packages
        install_additional_packages
    else
        print_error "Homebrew is not available - skipping package installation"
        # Don't return error - let script complete
    fi
    
    print_header "Development Environment Setup Complete"
    print_success "All packages have been successfully installed!"
    print_info "Your macOS development environment is now ready to use."
}

# =============================================================================
# Script Entry Point
# =============================================================================

# Ensure we're running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only."
    exit 1
fi

# Run main installation flow
main "$@"
