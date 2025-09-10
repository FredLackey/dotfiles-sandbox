# Task 001: Initial Setup Script Implementation Plan

## Overview
Create the main `src/setup.sh` script that serves as the single entry point for the dotfiles installation process. This script will handle platform detection and routing to platform-specific setup scripts.

## Primary Objectives
1. Download and extract the repository without requiring git
2. Detect the operating system and platform type
3. Route to the appropriate platform-specific setup script
4. Ensure idempotent operation (safe to run multiple times)
5. Provide clear error handling and exit codes

## Implementation Steps

### Phase 1: Core Setup Script (`src/setup.sh`)

#### 1.1 Script Structure
- Use bash shebang: `#!/bin/bash`
- Implement main() function pattern
- Add comprehensive error handling with `set -e`
- Include clear comments for junior developers

#### 1.2 Repository Download Function
```bash
download_repository() {
    # Download tarball from GitHub using curl or wget
    # Extract to ~/dotfiles with tar
    # Handle both new installations and updates
}
```

Key features:
- Check if `~/dotfiles` already exists
- Use curl on macOS, wget on Linux
- Download from: `https://github.com/fredlackey/dotfiles-sandbox/tarball/main`
- Extract with `tar` stripping the top-level directory
- Preserve existing customizations if updating

#### 1.3 Platform Detection Function
```bash
detect_platform() {
    # Detect macOS via Darwin kernel
    # Detect WSL via /proc/version
    # Detect Ubuntu Server via /etc/os-release
    # Return platform identifier
}
```

Detection logic:
- macOS: Check `uname -s` for "Darwin"
- WSL: Check `/proc/version` for "Microsoft" or "WSL"
- Ubuntu Server: Check `/etc/os-release` and confirm no WSL markers

#### 1.4 Platform Routing Function
```bash
route_to_platform() {
    # Based on detected platform
    # Execute appropriate setup script
    # Handle unsupported platforms gracefully
}
```

Routing paths:
- macOS ’ `~/dotfiles/src/macos/setup.sh`
- WSL ’ `~/dotfiles/src/wsl/setup.sh`
- Ubuntu Server ’ `~/dotfiles/src/ubuntu/setup.sh`

### Phase 2: Platform-Specific Setup Scripts

#### 2.1 macOS Setup (`src/macos/setup.sh`)
Initial skeleton that will:
- Verify Xcode Command Line Tools
- Install Homebrew if not present
- Install git via Homebrew
- Initialize git repository in ~/dotfiles
- Print success message

#### 2.2 Ubuntu Setup (`src/ubuntu/setup.sh`)
Initial skeleton that will:
- Update APT package lists
- Install git and essential packages
- Initialize git repository in ~/dotfiles
- Print success message

#### 2.3 WSL Setup (`src/wsl/setup.sh`)
Initial skeleton that will:
- Update APT package lists
- Install git and essential packages
- Handle WSL-specific configurations
- Initialize git repository in ~/dotfiles
- Print success message

### Phase 3: Utility Functions

Create `src/common/utils.sh` with shared functions:
- `print_error()` - Standardized error output
- `print_success()` - Standardized success messages
- `print_info()` - Informational messages
- `check_command()` - Verify command availability
- `ensure_directory()` - Idempotent directory creation

Note: These utilities will be copied into each platform script to maintain self-contained execution (no sourcing).

## Critical Requirements

### Idempotency
- Check before creating directories
- Verify before installing packages
- Test for existing configurations before adding
- Support multiple executions without side effects

### No User Interaction
- No prompts or confirmations
- All decisions made programmatically
- Silent operation with clear exit codes
- Error messages to stderr, success to stdout

### Error Handling
- Exit immediately on any error
- Provide descriptive error messages
- Return appropriate exit codes
- Leave system in safe state on failure

## Testing Strategy

### Local Testing (Development)
1. Verify script syntax with `bash -n`
2. Check for shellcheck warnings
3. Review logic flow without execution
4. Ensure all functions follow main() pattern

### Target System Testing
1. Test on fresh VM installations
2. Verify idempotency with multiple runs
3. Test failure scenarios (network issues, missing permissions)
4. Validate platform detection accuracy

## Success Criteria

The initial setup script is complete when:
1. One-liner installation works on all three platforms
2. Repository is successfully downloaded and extracted
3. Platform detection correctly identifies the OS
4. Appropriate platform script is executed
5. Git is installed and repository initialized
6. Multiple executions cause no issues
7. Errors are handled gracefully with clear messages

## Next Steps

After completing the initial setup script:
1. Implement package installation logic for each platform
2. Add shell configuration (ZSH setup)
3. Configure development tools (Vim/Neovim, Node.js, Java)
4. Set up platform-specific optimizations
5. Add dotfile symlinking and management

## Files to Create

1. `src/setup.sh` - Main entry point
2. `src/macos/setup.sh` - macOS platform setup
3. `src/ubuntu/setup.sh` - Ubuntu Server setup
4. `src/wsl/setup.sh` - WSL Ubuntu setup
5. `src/common/utils.sh` - Shared utility functions (to be copied, not sourced)

## Notes

- Keep all scripts under 200 lines for maintainability
- Use clear variable names (avoid abbreviations)
- Add explanatory comments for complex logic
- Follow the established script pattern with main() function
- Ensure compatibility with default shell versions on each platform