# Dotfiles

Development environment setup for full-stack Node.js and Java developers across three target platforms.

## Overview

This repository automates the setup of complete development environments for software engineers specializing in full-stack Node.js and Java development. It configures essential developer tools, IDEs, build systems, and productivity utilities to enable productive coding whether in GUI or text-based environments.

The goal is to transform a fresh OS installation into a fully-configured developer workstation with all necessary tools for modern web development, API development, and enterprise Java applications.

### Target Environments

Currently supported environments:
1. **Windows WSL running Ubuntu** - Windows Subsystem for Linux with Ubuntu distribution
2. **Ubuntu Server 22.04 LTS** - Standalone Ubuntu server installations  
3. **macOS 15 (Sequoia)** - Current macOS desktop systems with Homebrew package management

Future platforms (planned after initial three are complete):
- **RHEL (Red Hat Enterprise Linux)** - Enterprise Linux distributions
- **AWS Linux** - Amazon's Linux distribution for EC2 instances

### Architecture

- **Interactive Shell**: ZShell (zsh) is the preferred target environment, using the version that ships with the system
- **Scripting Language**: Bash for all automation and setup scripts
- **Shell Philosophy**: Never install or upgrade shell interpreters - work with what's already available
- **Development Focus**: Full-stack Node.js and Java development with appropriate tooling for each platform
- **Primary IDE**: NeoVim configured as a full-featured IDE for text-based development across ALL platforms
  - Not using pre-configured distributions (LazyVim, AstroNvim, etc.)
  - Custom NeoVim configuration built from scratch for our specific needs
  - ZSH + NeoVim provides the core development experience
- **Supplementary Tools**: GUI tools (VS Code) available on macOS for convenience when working in desktop environments

## Project Structure

### Active Development

- **`src/`** - Main source code and configuration files for dotfiles installation
- **`docs/`** - Project documentation and implementation guides
- **`knowledge/`** - Reference materials and configuration guides for tools and technologies

#### Source Organization (`src/`)

The source directory is organized by platform specificity:

- **`src/common/`** - Shared utilities that work across platforms
  - Common utility functions for setup scripts
  - Cross-platform helper functions
  - Shared setup logic

- **`src/macos/`** - macOS-specific implementations
  - Homebrew package installations
  - Development tools: Node.js, npm, Java JDK, Maven, Gradle
  - GUI IDEs: VS Code, IntelliJ IDEA (optional)
  - Xcode command line utilities setup
  - macOS system preferences and defaults
  - Docker Desktop and container tools
  - Database clients and tools

- **`src/ubuntu/`** - Ubuntu-specific implementations  
  - APT package management and system configuration
  - Development tools: Node.js (via nvm), npm/yarn/pnpm, OpenJDK 17, Maven, Gradle
  - Text-based IDE: NeoVim with multiple configuration options (minimal, full, IDE)
  - Complete configuration files in `configs/` directory:
    - Multiple NeoVim configurations (nvim, nvim-ide, nvim-minimal)
    - Oh My Zsh and ZSH templates and configurations
    - Tmux configuration with productivity enhancements
  - Build essentials, Docker, and LSP servers for development
  - Python development tools and language servers

- **`src/wsl/`** - WSL-specific implementations
  - Ubuntu base with Windows interoperability
  - Development tools matching Ubuntu Server
  - Special handling for Windows filesystem integration
  - WSL-specific optimizations for cross-platform development
  - Windows clipboard integration and aliases

#### Platform Strategy

Each of our three target platforms has its own independent folder with complete, self-contained scripts. We intentionally duplicate code across platforms for simplicity - avoiding complex conditional logic and dynamic platform detection. This means:

- **Single entry point** - `src/setup.sh` is the only script that detects the platform
- **No other adaptive configurations** - each platform has its own version of every script
- **Code duplication is acceptable** - identical code may exist in multiple platform folders
- **Platform-specific implementations** - each OS handles its own installation and configuration
- **Common folder is limited** - only truly universal functionality that requires no OS-specific behavior
- **Simplicity over DRY** - we prioritize maintainability and clarity over avoiding duplication
- **WSL-specific considerations** - WSL Ubuntu may have unique scripts for Windows interoperability

#### Additional Components

- **`src/extras/`** - Additional platform-specific tools and utilities
  - Windows PowerShell scripts for Windows-native setup
  - Alternative installation methods
  - Supplementary tools and configurations

- **`src/utils/`** - Core utility functions used by platform setup scripts
  - OS detection and environment verification
  - Common output formatting and execution functions
  - Shared helper functions for all platform scripts

### Reference Materials

The following directories contain reference materials that can be learned from but follow different practices than this project:

#### _examples/alrra
- **Fully functional working dotfiles project** compatible with macOS and Ubuntu
- **Trusted reference** for learning techniques and patterns  
- **Uses source methodology** where scripts source other scripts (we will NOT adopt this pattern)
- Can be deployed and used as-is on target systems
- We will learn from this project and adapt its concepts to our architecture

#### _legacy
- **Fully functional working dotfiles project** currently in production use
- Based on an older version of _examples/alrra
- **Targets multiple Ubuntu versions and WSL** in addition to macOS
- **Uses source methodology** that makes scripts difficult to test in isolation
- Contains working examples but follows outdated practices that conflict with current architecture

### Documentation and Knowledge Base

- **`docs/`** - Contains comprehensive project documentation:
  - `FOLDER_STRUCTURE.md` - Detailed explanation of the project organization
  - `INSTALLATION_PROCESS.md` - Step-by-step installation and configuration guides

- **`knowledge/`** - Reference materials for tools and technologies used:
  - Configuration guides for Oh My Zsh, Neovim, Chocolatey
  - Shell comparison and theme configuration
  - Tool-specific setup and customization instructions
  - Best practices and troubleshooting guides

> ⚠️ **Important Script Methodology Difference**:
> - **_examples/alrra and _legacy use source-based scripts** where files source each other
> - **We will NOT use this pattern** as it makes scripts difficult to test in isolation
> - **Our approach**: Every script contains a self-contained main() function and is directly executable
> - While we learn from and adapt code from these references, we will restructure it to follow our patterns
> - Do not copy code directly without understanding and adapting to our main() function architecture

## Development Philosophy

### Current Focus
- **Three target environments**: Windows WSL Ubuntu, Ubuntu Server 22.04 LTS, macOS 15
- **Developer productivity**: Automated setup of complete development environments
- **Full-stack readiness**: Node.js (via nvm), Java 17, build tools, containers, LSP servers
- **IDE mastery**: NeoVim configured as a powerful IDE for text-based development
  - Multiple configuration tiers: minimal (basic), full (with plugins), IDE (with LSP)
  - Language servers for TypeScript, Python, Java, Bash, YAML, JSON, and Lua
  - File explorer (neo-tree), fuzzy finder (telescope), git integration (lazygit)
  - Works consistently across SSH sessions, containers, and local terminals
  - No dependency on pre-built distributions - full control over our setup
- Clean, documented, and maintainable code
- Platform-specific implementations optimized for developer workflows

### Design Principles
- **Each script MUST be idempotent** (can be run multiple times safely) - THIS IS CRITICAL
- Use the shell interpreter that ships with the target environment (never install/upgrade shells)
- Comprehensive documentation for all configurations
- Small, focused files (< 200 lines)
- No installation of packages during development (this repo is for deployment elsewhere)
- **Scripts must run without human intervention** (no prompts, no confirmations, fully automated)
- **Write for junior developer comprehension** (clear variable names, explanatory comments, avoid clever one-liners)
- **Every script uses a main() function** - self-contained and directly executable

### Implementation Considerations
- Separate, independent implementations for each of the three target platforms
- WSL Ubuntu may require special handling for Windows filesystem integration
- Common software tools (Vim, Node.js, etc.) installed per-platform with OS-specific methods
- Each platform folder contains complete, self-contained setup scripts
- Modular design for easy customization within each platform
- Ubuntu Server and WSL Ubuntu may share some scripts but remain in separate folders for clarity

## Deployment Model

This repository uses a one-liner installation that automatically downloads and executes the setup:

### macOS Installation
```bash
bash -c "$(curl -LsS https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/setup.sh)"
```

### Ubuntu/WSL Installation
```bash
bash -c "$(wget -qO - https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/setup.sh)"
```

The setup script will:
1. Download the repository as a tarball (no git required)
2. Extract the archive to `~/dotfiles` 
3. Detect your operating system (macOS, Ubuntu Server, or WSL)
4. Install git and other essential tools
5. Initialize the extracted folder as a git repository for future updates
6. Execute the appropriate platform-specific setup
7. Configure your entire development environment without any prompts or manual intervention

**What gets installed:**
- **Development runtimes**: Node.js v20 LTS (via nvm), npm/yarn/pnpm, Java JDK 17, Python 3
- **Build tools**: Maven, Gradle, Make, cmake, build-essential, autoconf
- **Version control**: Git with enhanced configuration, lazygit GUI
- **Containers**: Docker CE (Ubuntu/WSL) or Docker Desktop (macOS)
- **Primary IDE**: NeoVim with tiered configurations
  - **Minimal**: Basic Neovim with essential plugins
  - **Full**: Complete setup with Treesitter and advanced plugins  
  - **IDE**: Full LSP integration with language servers, debugging, and formatting
  - File explorer (neo-tree), fuzzy finder (telescope), git integration
- **Supplementary editor**: VS Code (macOS only, for GUI convenience)
- **Terminal environment**: 
  - ZSH with Oh My Zsh framework and productivity plugins
  - tmux with custom configuration for session management
  - Powerline fonts and themes for enhanced terminal experience
- **Language servers**: TypeScript, Python, Bash, YAML, JSON, Lua, HTML/CSS
- **Code tools**: Prettier, Black, ESLint, ripgrep, fd-find, fzf, xclip
- **Platform-specific enhancements**:
  - macOS: Homebrew packages, Terminal.app themes, Touch ID for sudo
  - WSL: Windows interoperability, clipboard integration, locale configuration
  - Ubuntu: APT packages, systemd integration, swap configuration
- **Developer utilities**: jq, curl, wget, tree, htop, ncdu

**Important**: Setup scripts will run completely unattended - no user interaction required. The goal is to configure a new machine from start to finish without prompts or manual intervention.

### Update Workflow

The intended workflow supports continuous improvement through regular updates:

1. **Update**: `git pull` to get the latest changes
2. **Execute**: Run `src/setup.sh` to apply new configurations
3. **Repeat**: This process can be repeated unlimited times safely (idempotent execution)

## Critical Design Requirement: Idempotency

### ⚠️ THIS IS NON-NEGOTIABLE
**ALL scripts and configurations MUST be idempotent** - capable of being executed multiple times without causing problems, duplications, or inconsistencies. Users will run `git pull` and re-execute scripts repeatedly. Every script must produce the same result whether run once or a hundred times.

### Implementation Guidelines

- **Never blindly append** to configuration files
- **Always check** if a setting already exists before adding it
- **Verify current state** before making changes
- **Use conditional logic** to determine if action is needed
- **Validate** that multiple executions produce the same result
- **Test for existence** before creating files, directories, or settings

### Examples of Idempotent Patterns

```bash
# BAD: Blindly appends (creates duplicates on each run)
echo "export PATH=$PATH:/new/path" >> ~/.bashrc

# GOOD: Check if already present before adding
if ! grep -q "/new/path" ~/.bashrc; then
    echo "export PATH=$PATH:/new/path" >> ~/.bashrc
fi

# BAD: Always creates directory (may error if exists)
mkdir ~/my-directory

# GOOD: Check existence first
if [ ! -d ~/my-directory ]; then
    mkdir ~/my-directory
fi

# BETTER: Use mkdir -p (idempotent by design)
mkdir -p ~/my-directory

# BAD: Always installs package (may fail or cause issues)
brew install git

# GOOD: Check if already installed
if ! command -v git &> /dev/null; then
    brew install git
fi
```

## Getting Started

The repository includes complete, working setup scripts for all three target platforms. Each platform script installs and configures a full development environment without requiring user interaction during the installation process.

## Contributing

When working on this project:
- Do not create files unless explicitly requested
- Keep all scripts idempotent
- Document the purpose and behavior of all configurations
- Test on target systems before committing

---

*This dotfiles setup creates production-ready development environments for full-stack engineers, prioritizing developer productivity and maintainability.*
