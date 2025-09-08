# Dotfiles

A fresh approach to dotfiles configuration for macOS and Ubuntu systems.

## Overview

This repository represents a new dotfiles effort designed to replace the current dotfiles setup with a more thoughtful, documented, and maintainable approach.

### Architecture

- **Interactive Shell**: ZShell (zsh) is the preferred target environment, using the version that ships with the system
- **Scripting Language**: Bash for all automation and setup scripts
- **Target Platforms**: macOS (current focus), WSL, Windows, and Ubuntu (future)
- **Shell Philosophy**: Never install or upgrade shell interpreters - work with what's already available

## Project Structure

### Active Development

- **`src/`** - Main source code and configuration files for dotfiles installation
- **`scripts/`** - Repository-level utilities (git operations, documentation updates, etc.)

#### Source Organization (`src/`)

The source directory is organized by platform specificity:

- **`src/common/`** - Shared configurations that work across platforms
  - Shell configurations (primarily zsh interactive, bash scripts) targeting common platform features
  - Universal aliases, functions, and exports
  - Cross-platform compatible settings

- **`src/macos/`** - macOS-specific implementations
  - Homebrew package installations
  - Xcode command line utilities setup
  - macOS system preferences and defaults
  - Platform-specific optimizations

- **`src/ubuntu/`** - Ubuntu-specific implementations  
  - APT package management
  - GNOME desktop environment configurations
  - Ubuntu-specific system utilities
  - Distribution-specific settings

#### Platform Strategy

Each platform (macOS, Ubuntu, WSL, Windows) has its own independent folder with complete, self-contained scripts. We intentionally duplicate code across platforms for simplicity - avoiding complex conditional logic and dynamic platform detection. This means:

- **No adaptive configurations** - each platform has its own version of every script
- **Code duplication is acceptable** - identical code may exist in multiple platform folders
- **Platform-specific implementations** - each OS handles its own installation and configuration
- **Common folder is limited** - only truly universal functionality that requires no OS-specific behavior
- **Simplicity over DRY** - we prioritize maintainability and clarity over avoiding duplication

#### Repository Scripts (`scripts/`)

The scripts folder contains repository maintenance utilities:
- Git workflow automation
- Documentation generation
- Code quality checks
- Repository maintenance tasks

**Note**: Repository scripts are distinct from installation scripts and do not perform any system configuration.

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

#### _archive
- Previous attempt at dotfiles automation (auto-generated, undocumented)
- **DO NOT TRUST** - contains bloated, undocumented code
- Kept for reference of what NOT to do

> ⚠️ **Important Script Methodology Difference**:
> - **_examples/alrra and _legacy use source-based scripts** where files source each other
> - **We will NOT use this pattern** as it makes scripts difficult to test in isolation
> - **Our approach**: Every script contains a self-contained main() function and is directly executable
> - While we learn from and adapt code from these references, we will restructure it to follow our patterns
> - Do not copy code directly without understanding and adapting to our main() function architecture

## Development Philosophy

### Current Focus
- **macOS only** during initial development cycle
- Ubuntu support planned for future iterations
- Clean, documented, and maintainable code
- Manual review and understanding of all configurations

### Design Principles
- **Each script MUST be idempotent** (can be run multiple times safely) - THIS IS CRITICAL
- Use the shell interpreter that ships with the target environment (never install/upgrade shells)
- Comprehensive documentation for all configurations
- Small, focused files (< 200 lines)
- No installation of packages during development (this repo is for deployment elsewhere)
- **Scripts must run without human intervention** (no prompts, no confirmations, fully automated)
- **Write for junior developer comprehension** (clear variable names, explanatory comments, avoid clever one-liners)
- **Every script uses a main() function** - self-contained and directly executable

### Future Considerations
- Separate, independent implementations for each supported platform
- WSL and Windows support with their own dedicated script folders
- Common software tools (Vim, Node.js, etc.) installed per-platform with OS-specific methods
- Each platform folder contains complete, self-contained setup scripts
- Modular design for easy customization within each platform

## Deployment Model

This repository is designed to be cloned directly onto the target machine and executed locally:

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
# Execute setup scripts (to be implemented)
```

**Important**: Setup scripts will run completely unattended - no user interaction required. The goal is to configure a new machine from start to finish without prompts or manual intervention.

### Update Workflow

The intended workflow supports continuous improvement through regular updates:

1. **Update**: `git pull` to get the latest changes
2. **Execute**: Run setup scripts to apply new configurations
3. **Repeat**: This process can be repeated unlimited times safely

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

This project is currently in active development. Setup scripts and documentation will be added as features are implemented.

## Contributing

When working on this project:
- Do not create files unless explicitly requested
- Keep all scripts idempotent
- Document the purpose and behavior of all configurations
- Test on target systems before committing

---

*This dotfiles setup prioritizes understanding and maintainability over convenience.*
