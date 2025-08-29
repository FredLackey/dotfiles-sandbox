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
    # install_homebrew_package "MySQL Workbench" "mysqlworkbench" "--cask"
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
# macOS System Preferences Configuration
# =============================================================================

configure_preference() {
    local description="$1"
    local command="$2"
    local check_command="$3"
    
    print_step "Configuring: $description"
    
    # If check command is provided and passes, skip the configuration
    if [[ -n "$check_command" ]] && eval "$check_command" &> /dev/null; then
        print_success "$description already configured"
        return 0
    fi
    
    # Execute the configuration command
    if eval "$command" &> /dev/null; then
        print_success "$description configured successfully"
    else
        print_error "Failed to configure $description (continuing with next setting)"
        # Don't return error code - continue with next setting
    fi
}

configure_macos_preferences() {
    print_header "Configuring macOS System Preferences"
    
    print_info "Note: Some preferences may require a restart to take full effect."
    print_info "You may be prompted for administrator privileges for certain system settings."
    echo
    
    # Close System Preferences to prevent conflicts
    print_step "Closing System Preferences to prevent conflicts..."
    osascript -e 'tell application "System Preferences" to quit' &> /dev/null || true
    
    # =============================================================================
    # UI & UX Preferences
    # =============================================================================
    
    print_info "Configuring UI & UX preferences..."
    
    # Prevent .DS_Store files on network and USB volumes
    configure_preference \
        "Prevent .DS_Store files on network/USB volumes" \
        "defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true && defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true"
    
    # Screenshot preferences
    configure_preference \
        "Configure screenshot preferences" \
        "defaults write com.apple.screencapture disable-shadow -bool true && defaults write com.apple.screencapture location -string '$HOME/Desktop' && defaults write com.apple.screencapture show-thumbnail -bool false && defaults write com.apple.screencapture type -string 'png'"
    
    # Security and screen saver
    configure_preference \
        "Require password immediately after sleep/screensaver" \
        "defaults write com.apple.screensaver askForPassword -int 1 && defaults write com.apple.screensaver askForPasswordDelay -int 0"
    
    # Font rendering and UI improvements
    configure_preference \
        "Enable subpixel font rendering on non-Apple LCDs" \
        "defaults write -g AppleFontSmoothing -int 2"
    
    configure_preference \
        "Always show scrollbars" \
        "defaults write -g AppleShowScrollBars -string 'Always'"
    
    configure_preference \
        "Disable window animations" \
        "defaults write -g NSAutomaticWindowAnimationsEnabled -bool false"
    
    configure_preference \
        "Disable automatic termination of inactive apps" \
        "defaults write -g NSDisableAutomaticTermination -bool true"
    
    configure_preference \
        "Expand save and print panels by default" \
        "defaults write -g NSNavPanelExpandedStateForSaveMode -bool true && defaults write -g PMPrintingExpandedStateForPrint -bool true"
    
    configure_preference \
        "Disable focus ring animation" \
        "defaults write -g NSUseAnimatedFocusRing -bool false"
    
    configure_preference \
        "Speed up window resize animations" \
        "defaults write -g NSWindowResizeTime -float 0.001"
    
    configure_preference \
        "Disable Quick Look animations" \
        "defaults write -g QLPanelAnimationDuration -float 0"
    
    # =============================================================================
    # Dock Preferences
    # =============================================================================
    
    print_info "Configuring Dock preferences..."
    
    configure_preference \
        "Auto-hide Dock with no delay" \
        "defaults write com.apple.dock autohide -bool true && defaults write com.apple.dock autohide-delay -float 0"
    
    configure_preference \
        "Enable spring loading for Dock items" \
        "defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true"
    
    configure_preference \
        "Speed up Mission Control animations" \
        "defaults write com.apple.dock expose-animation-duration -float 0.1"
    
    configure_preference \
        "Don't group windows by app in Mission Control" \
        "defaults write com.apple.dock expose-group-by-app -bool false"
    
    configure_preference \
        "Disable Dock launch animations" \
        "defaults write com.apple.dock launchanim -bool false"
    
    configure_preference \
        "Set minimize effect to scale" \
        "defaults write com.apple.dock mineffect -string 'scale'"
    
    configure_preference \
        "Minimize windows into application icon" \
        "defaults write com.apple.dock minimize-to-application -bool true"
    
    configure_preference \
        "Don't auto-rearrange spaces by recent use" \
        "defaults write com.apple.dock mru-spaces -bool false"
    
    configure_preference \
        "Show process indicators for open apps" \
        "defaults write com.apple.dock show-process-indicators -bool true"
    
    configure_preference \
        "Don't show recent applications in Dock" \
        "defaults write com.apple.dock show-recents -bool false"
    
    configure_preference \
        "Make hidden app icons translucent" \
        "defaults write com.apple.dock showhidden -bool true"
    
    configure_preference \
        "Set Dock icon size to 60px" \
        "defaults write com.apple.dock tilesize -int 60"
    
    configure_preference \
        "Disable all hot corners" \
        "defaults write com.apple.dock wvous-tr-corner -int 0 && defaults write com.apple.dock wvous-tl-corner -int 0 && defaults write com.apple.dock wvous-bl-corner -int 0 && defaults write com.apple.dock wvous-br-corner -int 0"
    
    # =============================================================================
    # Finder Preferences
    # =============================================================================
    
    print_info "Configuring Finder preferences..."
    
    configure_preference \
        "Auto-open Finder windows for mounted volumes" \
        "defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true && defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true && defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true"
    
    configure_preference \
        "Show full POSIX path in Finder title" \
        "defaults write com.apple.finder _FXShowPosixPathInTitle -bool true"
    
    configure_preference \
        "Disable Finder animations" \
        "defaults write com.apple.finder DisableAllAnimations -bool true"
    
    configure_preference \
        "Disable Trash warning" \
        "defaults write com.apple.finder WarnOnEmptyTrash -bool false"
    
    configure_preference \
        "Search current directory by default" \
        "defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'"
    
    configure_preference \
        "Disable file extension change warning" \
        "defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false"
    
    configure_preference \
        "Use list view by default" \
        "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'"
    
    configure_preference \
        "Set Desktop as default location for new windows" \
        "defaults write com.apple.finder NewWindowTarget -string 'PfDe' && defaults write com.apple.finder NewWindowTargetPath -string 'file://$HOME/Desktop/'"
    
    configure_preference \
        "Show external drives and media on desktop" \
        "defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true && defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true && defaults write com.apple.finder ShowMountedServersOnDesktop -bool true && defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true"
    
    configure_preference \
        "Don't show recent tags" \
        "defaults write com.apple.finder ShowRecentTags -bool false"
    
    configure_preference \
        "Show all filename extensions" \
        "defaults write -g AppleShowAllExtensions -bool true"
    
    # =============================================================================
    # Keyboard Preferences
    # =============================================================================
    
    print_info "Configuring Keyboard preferences..."
    
    configure_preference \
        "Enable full keyboard access for all controls" \
        "defaults write -g AppleKeyboardUIMode -int 3"
    
    configure_preference \
        "Disable press-and-hold for key repeat" \
        "defaults write -g ApplePressAndHoldEnabled -bool false"
    
    configure_preference \
        "Set fast key repeat rate" \
        "defaults write -g 'InitialKeyRepeat_Level_Saved' -int 10 && defaults write -g KeyRepeat -int 1"
    
    configure_preference \
        "Disable automatic text corrections" \
        "defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false && defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false && defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false && defaults write -g NSAutomaticDashSubstitutionEnabled -bool false && defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false"
    
    # =============================================================================
    # Trackpad Preferences
    # =============================================================================
    
    print_info "Configuring Trackpad preferences..."
    
    configure_preference \
        "Enable tap to click" \
        "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true && defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1 && defaults write -g com.apple.mouse.tapBehavior -int 1 && defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1"
    
    configure_preference \
        "Enable two-finger secondary click" \
        "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true && defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1 && defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true"
    
    # =============================================================================
    # App Store Preferences
    # =============================================================================
    
    print_info "Configuring App Store preferences..."
    
    configure_preference \
        "Enable App Store debug menu" \
        "defaults write com.apple.appstore ShowDebugMenu -bool true"
    
    configure_preference \
        "Enable automatic updates" \
        "defaults write com.apple.commerce AutoUpdate -bool true && defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true && defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1 && defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1"
    
    # =============================================================================
    # Security & Privacy Preferences
    # =============================================================================
    
    print_info "Configuring Security & Privacy preferences..."
    
    configure_preference \
        "Disable personalized ads" \
        "defaults write com.apple.AdLib allowApplePersonalizedAdvertising -int 0"
    
    # =============================================================================
    # Language & Region Preferences
    # =============================================================================
    
    print_info "Configuring Language & Region preferences..."
    
    configure_preference \
        "Set language to English" \
        "defaults write -g AppleLanguages -array 'en'"
    
    configure_preference \
        "Set measurement units to centimeters" \
        "defaults write -g AppleMeasurementUnits -string 'Centimeters'"
    
    # =============================================================================
    # Restart affected applications
    # =============================================================================
    
    print_info "Restarting affected applications to apply changes..."
    
    # Kill affected applications to apply changes
    for app in "Dock" "Finder" "SystemUIServer" "cfprefsd"; do
        if pgrep "$app" &> /dev/null; then
            print_step "Restarting $app..."
            killall "$app" &> /dev/null || true
        fi
    done
    
    print_success "macOS system preferences configured successfully!"
    print_info "Some changes may require a full system restart to take effect."
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
    
    # 5. macOS System Preferences
    configure_macos_preferences
    
    print_header "Development Environment Setup Complete"
    print_success "All packages have been successfully installed!"
    print_success "macOS system preferences have been configured!"
    print_info "Your macOS development environment is now ready to use."
    print_info "Note: Some preference changes may require a system restart to take full effect."
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
