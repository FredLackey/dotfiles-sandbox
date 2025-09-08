# Installation Process

## Overview

This document outlines the installation process for deploying dotfiles on any of our three supported environments: Windows WSL Ubuntu, Ubuntu Server 22.04 LTS, or macOS 15 (Sequoia).

## Prerequisites

Before beginning the installation:

1. **Internet connection** required for:
   - Downloading the setup script
   - Cloning the repository
   - Installing packages during setup

2. **Administrative privileges** needed for:
   - Installing system packages
   - Modifying system preferences
   - Creating directories in system locations

3. **Basic tools** must be present:
   - macOS: `curl` (ships with the OS)
   - Ubuntu/WSL: `wget` (ships with the OS)

## Installation Steps

### Step 1: Execute the One-Liner Installation

The entire installation process begins with a single command that downloads and executes the setup script:

#### For macOS:

    bash -c "$(curl -LsS https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/setup.sh)"

#### For Ubuntu/WSL:

    bash -c "$(wget -qO - https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/setup.sh)"

**Note**: During development, the repository is hosted at `dotfiles-sandbox`. Once finalized, it will replace the production repository at `https://github.com/FredLackey/dotfiles`.

### Step 2: Automatic Repository Setup

The setup script will automatically:

1. **Download the repository** as a compressed tarball archive
2. **Extract the archive** to `~/dotfiles` using built-in `tar` command
3. **Detect your operating system** automatically
4. **Determine the platform type** (macOS, Ubuntu Server, or WSL)
5. **Execute the appropriate platform-specific setup**

**Note**: Git is not required at this stage. The repository is downloaded as a tarball using `curl` or `wget`, which are already available on all target systems. Git will be installed later as part of the platform-specific setup process.

#### How the Tarball Download Works

The setup script uses a clever approach that eliminates the need for git to be pre-installed:

1. **Downloads a tarball** from GitHub using the URL:
   - `https://github.com/fredlackey/dotfiles-sandbox/tarball/main`
2. **Uses native tools** that ship with each OS:
   - macOS: Uses `curl` (always available)
   - Ubuntu/WSL: Uses `wget` (always available)
3. **Extracts with tar** command (available on all Unix systems):
   - Strips the top-level directory from the archive
   - Places contents directly into `~/dotfiles`
4. **Installs Git later** during the platform-specific setup phase
5. **Initializes Git repository** after Git is installed for future updates

This approach ensures zero prerequisites beyond what the operating system provides by default.

### Step 3: Automatic Platform Detection

The `src/setup.sh` script performs the following detection:

#### macOS Detection
- Checks for Darwin kernel using `uname -s`
- Verifies macOS version compatibility
- Routes to `src/macos/setup.sh`

#### WSL Detection
- Examines `/proc/version` for Microsoft or WSL markers
- Confirms WSL version (WSL1 vs WSL2)
- Routes to `src/wsl/setup.sh`

#### Ubuntu Server Detection
- Identifies Ubuntu through `/etc/os-release`
- Verifies absence of WSL markers
- Confirms version 22.04 LTS
- Routes to `src/ubuntu/setup.sh`

### Step 4: Platform-Specific Installation

Once the platform is detected, the appropriate setup script takes over:

#### macOS Installation (`src/macos/setup.sh`)
1. Verifies Xcode Command Line Tools
2. Installs Homebrew package manager
3. Installs Git and other essential tools via Homebrew
4. Installs packages via Homebrew
5. Configures macOS system preferences
6. Sets up shell environment (ZSH)
7. Configures Terminal.app
8. Initializes Git repository for future updates

#### Ubuntu Server Installation (`src/ubuntu/setup.sh`)
1. Updates APT package lists
2. Installs Git and build essentials
3. Installs other essential packages
4. Configures system preferences
5. Sets up shell environment (ZSH)
6. Configures console/TTY settings
7. Initializes Git repository for future updates

#### WSL Ubuntu Installation (`src/wsl/setup.sh`)
1. Updates APT package lists
2. Installs Git and build essentials
3. Installs other essential packages
4. Configures WSL-specific settings
5. Sets up Windows interoperability
6. Sets up shell environment (ZSH)
7. Configures Windows Terminal integration
8. Initializes Git repository for future updates

## Installation Behavior

### Fully Automated Execution

The installation process is designed to be **completely unattended**:

- **No user prompts** during execution
- **No confirmation dialogs** for any action
- **No manual intervention** required
- **Automatic decision making** based on detected environment
- **Silent progress** with clear error reporting

### Idempotent Installation

The entire installation process is **idempotent** and can be run multiple times safely:

- **First run**: Performs full installation and configuration
- **Subsequent runs**: Verifies and updates only what's needed
- **No duplications**: Checks before adding configurations
- **No conflicts**: Validates current state before changes
- **Safe updates**: Can be used to apply repository updates

### Error Handling

If any part of the installation fails:

1. **Error is reported** with clear description
2. **Installation stops** immediately
3. **System remains in safe state** (no partial configurations)
4. **Exit code indicates failure** for automation tools
5. **Log indicates exact failure point** for debugging

## Update Process

After the initial installation, the repository will exist at `~/dotfiles`. To update an existing installation with the latest configurations:

    cd ~/dotfiles
    git pull origin main
    cd src
    ./setup.sh

The setup script will:
- Apply any new configurations
- Update existing settings as needed
- Maintain all customizations
- Preserve user data and preferences

Alternatively, you can re-run the one-liner installation command, which will update the existing repository and re-run the setup.

## Verification

After installation completes successfully:

1. **New shell session** will have all configurations active
2. **Aliases and functions** available immediately
3. **System preferences** applied (may require logout/login)
4. **Development tools** installed and configured

To verify the installation:

    # Check shell configuration
    echo $SHELL  # Should show /bin/zsh or /usr/bin/zsh
    
    # Test aliases (once configured)
    alias  # Lists all configured aliases
    
    # Verify git configuration
    git config --list  # Shows git settings

## Troubleshooting

### Permission Denied

If you get a permission error running setup.sh:

    chmod +x ~/dotfiles/src/setup.sh
    chmod +x ~/dotfiles/src/*/setup.sh

### Platform Not Detected

If the platform detection fails:
- Verify you're on a supported OS
- Check that required system files exist (`/proc/version`, `/etc/os-release`)
- Ensure you're running from within the src directory

### Package Installation Failures

If package installations fail:
- Verify internet connectivity
- Check for sufficient disk space
- Ensure administrative privileges
- Review package manager logs

## Manual Platform Selection

After the repository has been cloned to `~/dotfiles`, you can bypass detection and run platform-specific setups directly if needed:

    # For macOS
    ~/dotfiles/src/macos/setup.sh
    
    # For Ubuntu Server
    ~/dotfiles/src/ubuntu/setup.sh
    
    # For WSL Ubuntu
    ~/dotfiles/src/wsl/setup.sh

**Warning**: Running the wrong platform script may cause errors or unwanted configurations. The automatic detection in the main setup script is strongly recommended.

## Post-Installation

After successful installation:

1. **Start a new terminal session** to load all configurations
2. **Review installed packages** to ensure everything is present
3. **Test key functionality** like git, vim, and development tools
4. **Customize as needed** by editing files in `~/dotfiles/src/common/`

## Maintenance

The dotfiles repository is designed for continuous improvement:

- **Regular updates**: Pull latest changes periodically
- **Safe re-runs**: Execute setup.sh after updates
- **Version control**: Your customizations can be committed
- **Portable settings**: Easy to deploy on new machines

## Support

If installation fails or behaves unexpectedly:

1. Check the repository issues: https://github.com/FredLackey/dotfiles-sandbox/issues
2. Review the error output carefully
3. Ensure your system meets all prerequisites
4. Verify you're on a supported platform