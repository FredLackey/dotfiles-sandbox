# Windows Development Environment Setup

## Overview

This directory contains PowerShell scripts that automate the installation and configuration of a complete development environment on Windows 11 (and Windows 10 version 2004+). The setup is designed for full-stack developers working with Node.js, JavaScript, Java, C#/.NET, and containerized applications using Docker.

## What Gets Installed

### Package Manager
- **Chocolatey** - Windows package manager for automated software installation

### Core Development Tools
- **Git** - Version control system
- **Visual Studio Code** - Primary code editor
- **Windows Terminal** - Modern terminal application
- **PowerShell Core** - Cross-platform PowerShell 7+
- **7-Zip** - File compression utility

### Programming Languages & Runtimes
- **Node.js LTS** - JavaScript runtime (includes npm)
- **Yarn** - Fast, reliable JavaScript package manager
- **pnpm** - Efficient, disk space-saving package manager
- **TypeScript** - Typed superset of JavaScript
- **Python** - Required for many Node.js native modules
- **OpenJDK 17** - Java Development Kit (LTS version)
- **.NET SDK** - For C# and .NET development

### Build Tools & IDEs
- **Maven** - Java project management and build tool
- **Gradle** - Modern build automation tool
- **Make** - GNU Make for build automation
- **IntelliJ IDEA Ultimate** - Professional Java IDE with enterprise features (requires license)

### Container & Cloud Tools
- **Docker Desktop** - Container platform for Windows
- **GitHub CLI** - Command-line interface for GitHub

### Database Tools (Optional)
- **MongoDB** - NoSQL database
- **PostgreSQL** - Relational database
- **DBeaver** - Universal database management tool

### API Development Tools
- **Postman** - API testing and development
- **Insomnia** - REST API client

### Utilities
- **curl** - Command-line tool for transferring data
- **wget** - Network downloader
- **jq** - Command-line JSON processor

## Quick Start

### One-Line Installation

Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/install.ps1'))
```

This command will:
1. Download the setup script directly from GitHub
2. Execute it with appropriate permissions
3. Install all development tools automatically
4. Configure the environment for immediate use

## Installation Options

### Standard Installation
Installs everything including databases and Docker:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/install.ps1'))
```

### Minimal Installation
Installs only essential tools (Git, VS Code, Node.js):
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = (New-Object System.Net.WebClient).DownloadString('https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/setup.ps1'); iex "& { $script } -Minimal"
```

### Without Docker
Installs everything except Docker Desktop:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = (New-Object System.Net.WebClient).DownloadString('https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/setup.ps1'); iex "& { $script } -SkipDocker"
```

### Without Databases
Installs everything except database tools:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $script = (New-Object System.Net.WebClient).DownloadString('https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/setup.ps1'); iex "& { $script } -SkipDatabases"
```

## Local Installation

If you've already cloned the repository:

1. Open **PowerShell as Administrator**
2. Navigate to the repository:
   ```powershell
   cd path\to\dotfiles-sandbox\src\extras\windows
   ```
3. Run the setup script:
   ```powershell
   .\setup.ps1
   ```

With options:
```powershell
# Minimal installation
.\setup.ps1 -Minimal

# Skip Docker
.\setup.ps1 -SkipDocker

# Skip Databases
.\setup.ps1 -SkipDatabases

# Force reinstall all packages
.\setup.ps1 -Force
```

## Requirements

- **Windows 11** or **Windows 10** (version 2004 or higher)
- **PowerShell 5.1** or higher (comes with Windows)
- **Administrator privileges** (required for installation)
- **Internet connection** for downloading packages
- **.NET Framework 4.8** (installer will attempt to install if missing)
- **8GB RAM minimum** (16GB recommended for Docker)
- **25GB free disk space** for full installation

## Features

### > Completely Automated
- No user interaction required
- Automatic dependency resolution
- Silent installation mode
- Handles all confirmations automatically

### = Idempotent Design
- Safe to run multiple times
- Skips already installed packages
- Won't create duplicates or conflicts
- Includes `-Force` flag for reinstallation when needed

### =� Progress Tracking
- Color-coded output for clarity
- Real-time installation status
- Verification of each installation
- Summary report generated on Desktop

### � Optimized Performance
- Parallel package downloads when possible
- Disabled progress bars for faster execution
- Extended timeouts for large packages
- Cached package reuse

### =� Error Handling
- Comprehensive error catching
- Continues on non-critical failures
- Detailed error messages
- Fallback options for common issues

## Post-Installation

### Automatic Configuration
The script automatically:
- Configures Chocolatey for headless operation
- Sets npm registry to public registry
- Configures Git default branch to `main`
- Creates environment variables
- Updates system PATH

### Manual Steps Required
After installation, you should:

1. **Restart your computer** (required for Docker Desktop)
2. **Configure Git** with your identity:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
3. **Sign in to Docker Desktop** (optional, for Docker Hub access)
4. **Install VS Code extensions** for your preferred languages

### Verification
The script automatically verifies all installations and creates a summary file on your Desktop with:
- List of installed components
- Installation timestamps
- Version information
- Next steps guide

## Maintenance

### Update All Packages
```powershell
choco upgrade all -y
```

### Update Specific Package
```powershell
choco upgrade nodejs-lts -y
```

### Check Outdated Packages
```powershell
choco outdated
```

### List Installed Packages
```powershell
choco list --local-only
```

## Troubleshooting

### Common Issues

#### "Script cannot be loaded" Error
Run this first:
```powershell
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
```

#### "Not running as Administrator" Error
1. Right-click on PowerShell
2. Select "Run as Administrator"
3. Run the installation command again

#### Network/Proxy Issues
For corporate networks with proxy:
```powershell
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
```
Then run the installation command.

#### Installation Hangs
- Check internet connectivity
- Temporarily disable antivirus
- Use the `-Force` flag to retry

#### Docker Desktop Won't Start
1. Enable Hyper-V in Windows Features
2. Enable WSL 2
3. Restart computer
4. Ensure virtualization is enabled in BIOS

### Getting Help

If you encounter issues:
1. Check the summary file on your Desktop for installation details
2. Review the PowerShell output for specific error messages
3. Run individual package installations manually:
   ```powershell
   choco install package-name -y --force
   ```

## Script Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-Minimal` | Install only essential tools | `.\setup.ps1 -Minimal` |
| `-SkipDocker` | Skip Docker Desktop installation | `.\setup.ps1 -SkipDocker` |
| `-SkipDatabases` | Skip database tools | `.\setup.ps1 -SkipDatabases` |
| `-Force` | Force reinstall all packages | `.\setup.ps1 -Force` |

## Security Notes

- The script requires Administrator privileges to install system-wide packages
- All packages are downloaded from official Chocolatey Community Repository
- Chocolatey verifies package checksums for integrity
- The script sets execution policy only for the current process
- No permanent system security changes are made

## Customization

To customize the installation, edit `setup.ps1` and modify the package arrays:

```powershell
$corePackages = @(...)      # Essential tools
$nodePackages = @(...)       # Node.js ecosystem
$javaPackages = @(...)       # Java development
$dotnetPackages = @(...)     # .NET/C# development
$dockerPackages = @(...)     # Container tools
$databasePackages = @(...)   # Database tools
$utilityPackages = @(...)    # Additional utilities
```

## License

This script is part of the dotfiles-sandbox repository and follows the same license terms as the parent project.

## Support

For issues or questions:
- Review this README for troubleshooting steps
- Check the [Chocolatey documentation](https://docs.chocolatey.org/)
- Open an issue in the [repository](https://github.com/fredlackey/dotfiles-sandbox/issues)

## Credits

This setup script leverages:
- [Chocolatey](https://chocolatey.org/) - The Package Manager for Windows
- Package maintainers in the Chocolatey Community Repository
- Open source projects that make development on Windows awesome