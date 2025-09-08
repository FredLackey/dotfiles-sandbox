# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles configuration repository for macOS and Ubuntu systems. The repository is designed for **development only** - scripts are written here and deployed to target systems separately.

### Shell Philosophy
- **Interactive Shell**: ZShell (zsh) is the preferred target environment, using the version that ships with the system
- **Scripting Language**: Bash for all automation and setup scripts
- **Shell Management**: Never install or upgrade shell interpreters - work with what's already available on target systems

## Critical Development Rules

### DO NOT MODIFY THIS DEVELOPMENT SYSTEM
- **NO package installations** (brew, apt, npm, etc.)
- **NO system modifications** (preferences, configurations, settings)
- **NO file system changes** outside this repository
- **NO downloads** of external tools or binaries
- **NO execution** of installation or configuration commands

All scripts are developed here and executed on different target systems.

### Write for Junior Developers
- **Every script and document must be written so a junior developer can understand it**
- **Use clear, descriptive variable names** (avoid cryptic abbreviations)
- **Add explanatory comments** for non-obvious logic or system commands
- **Break complex operations** into smaller, understandable steps
- **Document the "why"** not just the "what" for design decisions
- **Avoid clever one-liners** in favor of readable, maintainable code
- **Provide examples** where concepts might be unclear

## Architecture and Structure

### Directory Organization

```
src/
├── common/    # Cross-platform configurations (bash, zsh, aliases, functions)
├── macos/     # macOS-specific implementations (Homebrew, Xcode, system preferences)
└── ubuntu/    # Ubuntu-specific implementations (APT, GNOME, distribution settings)

scripts/       # Repository maintenance utilities (git operations, documentation)
               # Note: Repository scripts do NOT perform system configuration

_legacy/       # Reference: Current production dotfiles (trusted but outdated practices)
_archive/      # Reference: Previous auto-generated attempt (DO NOT TRUST OR COPY)
_examples/     # Reference: Other developers' dotfiles (trusted reference for learning)
```

### ⚠️ Important Reference Folder Warning
- **`_archive/`** contains bloated, undocumented auto-generated code and should NOT be trusted
- **`_legacy/`** contains working examples but uses outdated practices that conflict with current architecture
- **`_examples/`** contains quality examples from other developers for learning techniques
- **Do not copy code directly from any reference folders without understanding and adapting to current practices**

### Important Design Patterns

1. **All scripts must be idempotent** - capable of being executed multiple times safely
2. **Every script uses a main() function** - never source scripts, always execute directly
3. **Scripts must check before modifying** - verify current state before making changes
4. **Small, focused files** - keep scripts under 200 lines

### Script Pattern Template

```bash
#!/usr/bin/env bash

# Script functions here...

main() {
    # All script logic goes here
    # Check if configuration exists before adding
    # Make idempotent changes only
}

# Execute main function when script is run directly
main "$@"
```

## Development Workflow

1. Write scripts that will install/configure on target systems
2. Use conditional logic to ensure idempotency
3. Document what scripts will do when deployed
4. Scripts will be executed via `git clone` on target systems

## Key Implementation Guidelines

### Idempotency Examples

```bash
# BAD: Blindly appends (creates duplicates)
echo "export PATH=$PATH:/new/path" >> ~/.bashrc

# GOOD: Check if already present
if ! grep -q "/new/path" ~/.bashrc; then
    echo "export PATH=$PATH:/new/path" >> ~/.bashrc
fi
```

### Platform Strategy

- **Current Focus**: macOS only during initial development cycle
- **Future Support**: Ubuntu, WSL, and Windows planned for future iterations
- **Common Folder**: Targets shared functionality that works across different shell environments
- **Platform Detection**: Scripts will detect available shell capabilities on target systems
- **Adaptive Configurations**: Zsh configurations that work with different versions across platforms
- **Fallback Strategies**: Graceful handling for systems where zsh is not available

## Repository Commands

Currently, this is a development repository with no build or test commands. Scripts are validated through:
- Code review and logic analysis
- Manual verification of script behavior
- Testing on actual target systems during deployment

## Deployment Model

Target systems will:
```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
# Execute platform-specific setup scripts
```

Updates are applied via `git pull` followed by re-running setup scripts.