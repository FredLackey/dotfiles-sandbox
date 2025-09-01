# Dotfiles

A fresh approach to dotfiles configuration for macOS and Ubuntu systems.

## Overview

This repository represents a new dotfiles effort designed to replace the current dotfiles setup with a more thoughtful, documented, and maintainable approach.

### Architecture

- **Primary Shell**: ZShell (zsh) for interactive terminal sessions
- **Scripting**: Bash for all automation and setup scripts
- **Target Platforms**: macOS (primary focus) and Ubuntu (future)

## Project Structure

### Active Development

- **`src/`** - Main source code and configuration files for dotfiles installation
- **`scripts/`** - Repository-level utilities (git operations, documentation updates, etc.)

#### Source Organization (`src/`)

The source directory is organized by platform specificity:

- **`src/common/`** - Shared configurations that work across platforms
  - Shell configurations (bash, zsh) targeting common platform features
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

The common folder targets shared functionality, though bash and zsh version compatibility between macOS and Ubuntu may require platform-specific implementations where universal approaches aren't feasible.

#### Repository Scripts (`scripts/`)

The scripts folder contains repository maintenance utilities:
- Git workflow automation
- Documentation generation
- Code quality checks
- Repository maintenance tasks

**Note**: Repository scripts are distinct from installation scripts and do not perform any system configuration.

### Reference Materials

The following directories contain reference materials that can be learned from but follow different practices than this project:

- **`_legacy/`** - Current production dotfiles stored as examples
- **`_archive/`** - Previous attempt at dotfiles automation (auto-generated, undocumented)
- **`_examples/`** - Collection of other developers' dotfiles for learning techniques

> ⚠️ **Important**: Reference directories (`_*`) contain examples only and should not be trusted for direct implementation. They may not follow current best practices or project goals.

## Development Philosophy

### Current Focus
- **macOS only** during initial development cycle
- Ubuntu support planned for future iterations
- Clean, documented, and maintainable code
- Manual review and understanding of all configurations

### Design Principles
- Each script must be idempotent (can be run multiple times safely)
- Comprehensive documentation for all configurations
- Small, focused files (< 200 lines)
- No installation of packages during development (this repo is for deployment elsewhere)

### Future Considerations
- Separate configuration sets for bash and zsh environments
- Support for systems without zsh availability
- Modular design for easy customization

## Deployment Model

This repository is designed to be cloned directly onto the target machine and executed locally:

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
# Execute setup scripts (to be implemented)
```

### Update Workflow

The intended workflow supports continuous improvement through regular updates:

1. **Update**: `git pull` to get the latest changes
2. **Execute**: Run setup scripts to apply new configurations
3. **Repeat**: This process can be repeated unlimited times safely

## Critical Design Requirement: Idempotency

**All scripts and configurations must be idempotent** - capable of being executed multiple times without causing problems or inconsistencies.

### Implementation Guidelines

- **Never blindly append** to configuration files
- **Always check** if a setting already exists before adding it
- **Verify current state** before making changes
- **Use conditional logic** to determine if action is needed
- **Validate** that multiple executions produce the same result

### Examples of Idempotent Patterns

```bash
# BAD: Blindly appends (creates duplicates)
echo "export PATH=$PATH:/new/path" >> ~/.bashrc

# GOOD: Check if already present
if ! grep -q "/new/path" ~/.bashrc; then
    echo "export PATH=$PATH:/new/path" >> ~/.bashrc
fi

# GOOD: Use tools that handle duplicates
# (Implementation details to be added as project develops)
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
