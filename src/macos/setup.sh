#!/bin/bash

# macOS-specific setup script for dotfiles
# This script configures a macOS system for full-stack development

# Exit on any error
set -e

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
        
        eval "$CMDS" &> "$TMP_FILE"
        exitCode=$?
        
        if [ $exitCode -eq 0 ]; then
            print_success "$MSG"
        else
            print_error "$MSG"
            # Show errors
            while read -r line; do
                print_error "↳ ERROR: $line"
            done < "$TMP_FILE"
        fi
        
        rm -rf "$TMP_FILE"
        return $exitCode
    }
    
    check_command() {
        command -v "$1" >/dev/null 2>&1
    }
fi

# Verify we're running on macOS
verify_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        print_error "This script is for macOS only"
        exit 1
    fi
    
    print_success "macOS environment verified"
}

# Check and install Xcode Command Line Tools
install_xcode_tools() {
    print_title "Xcode Command Line Tools"
    
    # Check if already installed
    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools (already installed)"
        return 0
    fi
    
    # Trigger the installation
    xcode-select --install &>/dev/null || true
    
    # Wait for installation to complete
    print_info "Installing Xcode Command Line Tools (this may take several minutes)..."
    
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    
    print_success "Xcode Command Line Tools"
}

# Install Homebrew package manager
install_homebrew() {
    print_title "Homebrew Package Manager"
    
    if check_command brew; then
        print_success "Homebrew (already installed)"
        execute "brew update" "Updating Homebrew"
        return 0
    fi
    
    # Download and run the official Homebrew installer
    execute "/bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)' </dev/null" \
            "Installing Homebrew"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        # Add to shell profile for future sessions
        if [ -f "$HOME/.zprofile" ]; then
            if ! grep -q "/opt/homebrew/bin/brew" "$HOME/.zprofile"; then
                execute "echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> '$HOME/.zprofile'" \
                        "Configuring Homebrew in shell profile"
            fi
        else
            execute "echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' > '$HOME/.zprofile'" \
                    "Creating shell profile with Homebrew"
        fi
    fi
    
    # Add Homebrew to PATH for Intel Macs
    if [ -f "/usr/local/bin/brew" ]; then
        export PATH="/usr/local/bin:$PATH"
    fi
}

# Install Git via Homebrew
install_git() {
    print_title "Git Version Control"
    
    # Check if git is already installed via Homebrew
    if brew list git &>/dev/null; then
        print_success "Git (already installed via Homebrew)"
        execute "brew upgrade git 2>/dev/null || true" "Updating Git"
    else
        execute "brew install git" "Git"
    fi
}

# Install essential development tools
install_essential_tools() {
    print_title "Essential Development Tools"
    
    # Core utilities
    local tools=(
        "coreutils"    # GNU core utilities
        "findutils"    # GNU find, locate, updatedb, xargs
        "grep"         # GNU grep
        "gnu-sed"      # GNU sed
        "gawk"         # GNU awk
        "tree"         # Directory listing
        "wget"         # Alternative to curl
        "jq"           # JSON processor
        "yq"           # YAML processor
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_success "$tool (already installed)"
        else
            execute "brew install '$tool'" "$tool"
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
        
        # Set up remote if not already configured
        if ! git remote | grep -q "origin"; then
            execute \
                "git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git'" \
                "Adding git remote origin"
        else
            print_success "Git remote origin (already configured)"
        fi
    else
        # Initialize new repository
        execute \
            "git init && \
             git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git' && \
             git fetch origin && \
             git reset --hard origin/main && \
             git branch --set-upstream-to=origin/main main" \
            "Initializing Git repository"
    fi
    
    cd - >/dev/null
}

# Configure shell environment (foundation for text-based development)
configure_shell() {
    print_title "Shell Environment"
    
    # Future configurations will include:
    # - ZSH enhancements (default on macOS)
    # - Shell prompt customization
    # - Aliases and functions for productivity
    # - PATH modifications
    # - Environment variables
    # - Command history improvements
    
    print_info "Shell environment configuration (coming soon)"
}

# Install text-based development environment (primary focus)
install_text_based_dev_environment() {
    print_title "Text-Based Development Environment"
    
    # Future installations will include:
    # - Vim/Neovim as primary IDE
    # - Vim plugins and configuration
    # - Tmux for terminal multiplexing
    # - Terminal-based file managers
    # - Command-line development tools
    
    print_info "Text-based development environment (coming soon)"
}

# Install visual development environment (macOS supplementary tools)
install_visual_dev_environment() {
    print_title "Visual Development Environment (Supplementary)"
    
    # Future installations will include:
    # - VS Code (for when GUI is convenient)
    # - IntelliJ IDEA (optional, for Java development)
    # - GUI Git clients (optional)
    # - Database GUI tools
    # - API testing tools (Postman, etc.)
    
    print_info "Visual development environment (coming soon)"
}

# Install programming languages and tools
install_programming_tools() {
    print_title "Programming Languages & Tools"
    
    # Future installations will include:
    # - Node.js and npm (via Homebrew)
    # - Java JDK (OpenJDK via Homebrew)
    # - Python (via Homebrew)
    # - Go
    # - Docker Desktop
    # - Build tools (make, cmake, etc.)
    
    print_info "Programming tools installation (coming soon)"
}

# Main function
main() {
    # Step 1: System verification and preparation
    verify_macos
    install_xcode_tools
    install_homebrew
    
    # Step 2: Core system tools
    install_git
    install_essential_tools
    initialize_git_repo
    
    # Step 3: Shell and terminal setup (foundation)
    configure_shell
    
    # Step 4: Text-based development environment (primary)
    install_text_based_dev_environment
    
    # Step 5: Programming languages and tools
    install_programming_tools
    
    # Step 6: Visual development environment (macOS bonus)
    install_visual_dev_environment
    
    print_title "Setup Complete!"
    print_success "macOS configured successfully"
    print_info "Some changes may require a new terminal session to take effect"
    
    return 0
}

# Execute main function when script is run directly
main "$@"