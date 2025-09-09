# Chocolatey Setup Guide for Windows 11 Development Environment

## Overview

This guide provides best practices for installing Chocolatey on Windows 11 and setting up a complete development environment for Node.js, JavaScript, and Java development with Docker support.

## Prerequisites

- Windows 11 (or Windows 10 version 2004 or higher)
- PowerShell 5.1 or higher
- .NET Framework 4.8 (installer will attempt to install if missing)
- Administrative privileges for installation

## Installation Process

### Step 1: Install Chocolatey

#### Option A: Standard Installation (Recommended)

1. **Open PowerShell as Administrator**
   - Right-click the Start button
   - Select "Windows Terminal (Admin)" or "PowerShell (Admin)"
   - Click "Yes" on the UAC prompt

2. **Check Execution Policy**
   ```powershell
   Get-ExecutionPolicy
   ```
   If it returns `Restricted`, run:
   ```powershell
   Set-ExecutionPolicy AllSigned
   ```
   Or for current process only:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
   ```

3. **Install Chocolatey**
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

4. **Verify Installation**
   ```powershell
   choco --version
   ```

#### Option B: Installation Behind Corporate Proxy

If you're behind a corporate proxy:

```powershell
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Step 2: Configure Chocolatey

1. **Set Cache Location** (optional but recommended)
   ```powershell
   choco config set cacheLocation C:\ProgramData\chocolatey\cache
   ```

2. **Enable Auto Confirmation** (optional, for automation)
   ```powershell
   choco feature enable -n allowGlobalConfirmation
   ```

3. **Set Timeout for Long Installations**
   ```powershell
   choco config set commandExecutionTimeoutSeconds 14400
   ```

## Development Environment Setup

### Core Development Tools

#### Essential Tools Installation Script

Create a PowerShell script `setup-dev-env.ps1`:

```powershell
# Windows 11 Development Environment Setup Script
# For Node.js, JavaScript, Java Development with Docker

Write-Host "Installing Development Environment..." -ForegroundColor Green

# Version Control
choco install git -y
choco install github-desktop -y  # Optional GUI for Git

# Text Editors and IDEs
choco install vscode -y
choco install notepadplusplus -y

# Node.js Development
choco install nodejs-lts -y      # LTS version of Node.js (includes npm)
choco install nvm -y              # Node Version Manager for Windows
choco install yarn -y             # Alternative package manager
choco install pnpm -y             # Fast, disk space efficient package manager

# Java Development
choco install openjdk17 -y       # OpenJDK 17 LTS
choco install maven -y            # Apache Maven
choco install gradle -y           # Gradle build tool
choco install intellijidea-ultimate -y  # IntelliJ IDEA Ultimate (Professional Java IDE)

# Container Tools
choco install docker-desktop -y   # Docker Desktop for Windows

# Database Tools
choco install mongodb -y          # MongoDB
choco install postgresql -y       # PostgreSQL
choco install dbeaver -y          # Universal database tool

# API Development & Testing
choco install postman -y         # API testing tool
choco install insomnia-rest-api-client -y  # Alternative API client

# Terminal & Shell Enhancements
choco install microsoft-windows-terminal -y
choco install powershell-core -y  # PowerShell 7+

# Utilities
choco install 7zip -y
choco install wget -y
choco install curl -y
choco install jq -y               # JSON processor

# Development Utilities
choco install python -y           # Python (often needed for Node.js native modules)
choco install make -y             # GNU Make
choco install gh -y               # GitHub CLI

Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "Please restart your terminal for all changes to take effect." -ForegroundColor Yellow
```

### Minimal Installation (Essential Only)

For a minimal setup with just the essentials:

```powershell
# Minimal setup for Node.js and Java development
choco install git nodejs-lts openjdk17 vscode docker-desktop -y
```

### Installation by Category

#### Node.js/JavaScript Development

```powershell
# Node.js and JavaScript tools
choco install nodejs-lts -y
choco install yarn -y
choco install pnpm -y
choco install typescript -y

# Optional: Install specific Node.js version
choco install nodejs --version=18.17.0 -y
```

#### Java Development

```powershell
# Java development tools
choco install openjdk17 -y      # or openjdk11, openjdk8
choco install maven -y
choco install gradle -y
choco install intellijidea-community -y  # Optional: IntelliJ IDEA

# Set JAVA_HOME automatically (handled by Chocolatey)
refreshenv
```

#### Docker and Containerization

```powershell
# Docker and container tools
choco install docker-desktop -y
choco install docker-compose -y
choco install kubernetes-cli -y
choco install kubernetes-helm -y
```

## Post-Installation Configuration

### 1. Verify Installations

```powershell
# Check Node.js and npm
node --version
npm --version

# Check Java
java -version
javac -version

# Check Docker (after restart)
docker --version
docker-compose --version

# Check Git
git --version
```

### 2. Configure npm Registry (Optional)

```powershell
# Set npm registry (if using corporate registry)
npm config set registry https://registry.npmjs.org/

# Configure npm prefix for global packages
npm config set prefix "$env:APPDATA\npm"
```

### 3. Configure Git

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

### 4. Docker Desktop Configuration

1. After installation, restart your computer
2. Launch Docker Desktop from the Start menu
3. Sign in with your Docker Hub account (optional)
4. Configure resources in Settings:
   - Memory: Allocate based on your system (e.g., 4GB minimum)
   - CPU: Allocate cores as needed
   - Enable WSL 2 integration if using WSL

## Maintenance and Updates

### Update All Packages

```powershell
# Update Chocolatey itself
choco upgrade chocolatey -y

# Update all installed packages
choco upgrade all -y
```

### Check Outdated Packages

```powershell
choco outdated
```

### Update Specific Package

```powershell
choco upgrade nodejs-lts -y
```

### Pin Package Version

To prevent automatic updates of critical packages:

```powershell
choco pin add -n=nodejs --version=18.17.0
```

## Automation Script

Complete setup script with error handling:

```powershell
# setup-windows-dev.ps1
# Complete Windows 11 Development Environment Setup

param(
    [switch]$SkipDocker = $false,
    [switch]$SkipJava = $false,
    [switch]$Minimal = $false
)

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
}

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "Starting Development Environment Setup..." -ForegroundColor Green

# Core tools
$corePackages = @('git', 'vscode', '7zip', 'microsoft-windows-terminal')

# Node.js packages
$nodePackages = @('nodejs-lts', 'yarn', 'pnpm')

# Java packages
$javaPackages = @('openjdk17', 'maven', 'gradle')

# Docker packages
$dockerPackages = @('docker-desktop')

# Install core packages
Write-Host "Installing core development tools..." -ForegroundColor Cyan
foreach ($package in $corePackages) {
    Write-Host "  Installing $package..." -ForegroundColor Gray
    choco install $package -y
}

# Install Node.js tools
Write-Host "Installing Node.js development tools..." -ForegroundColor Cyan
foreach ($package in $nodePackages) {
    Write-Host "  Installing $package..." -ForegroundColor Gray
    choco install $package -y
}

# Install Java tools (unless skipped)
if (-not $SkipJava -and -not $Minimal) {
    Write-Host "Installing Java development tools..." -ForegroundColor Cyan
    foreach ($package in $javaPackages) {
        Write-Host "  Installing $package..." -ForegroundColor Gray
        choco install $package -y
    }
}

# Install Docker (unless skipped)
if (-not $SkipDocker -and -not $Minimal) {
    Write-Host "Installing Docker Desktop..." -ForegroundColor Cyan
    choco install docker-desktop -y
    Write-Host "Note: System restart required for Docker Desktop" -ForegroundColor Yellow
}

# Refresh environment variables
Write-Host "Refreshing environment variables..." -ForegroundColor Cyan
refreshenv

# Verify installations
Write-Host "`nVerifying installations:" -ForegroundColor Green
Write-Host "Node.js version: $(node --version)" -ForegroundColor Gray
Write-Host "npm version: $(npm --version)" -ForegroundColor Gray
Write-Host "Git version: $(git --version)" -ForegroundColor Gray

if (-not $SkipJava -and -not $Minimal) {
    Write-Host "Java version: $(java -version 2>&1 | Select-String version)" -ForegroundColor Gray
}

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "Please restart your computer to ensure all tools work properly." -ForegroundColor Yellow
Write-Host "Docker Desktop will be available after restart." -ForegroundColor Yellow
```

## Troubleshooting

### Common Issues and Solutions

1. **PowerShell Execution Policy Error**
   ```powershell
   Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
   ```

2. **Installation Fails with TLS Error**
   ```powershell
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   ```

3. **Chocolatey Command Not Found After Installation**
   - Close and reopen PowerShell as Administrator
   - Or run: `refreshenv`

4. **Package Installation Hangs**
   - Check internet connectivity
   - Disable antivirus temporarily during installation
   - Use `--force` flag: `choco install packagename --force -y`

5. **Docker Desktop Won't Start**
   - Ensure Hyper-V is enabled
   - Enable WSL 2 feature
   - Restart computer after installation

## Best Practices

1. **Regular Updates**: Schedule weekly updates using Task Scheduler
2. **Version Pinning**: Pin critical packages in production environments
3. **Backup Package List**: Export installed packages regularly
   ```powershell
   choco export packages.config
   ```
4. **Use Configuration Files**: Create `.config` files for repeatable setups
5. **Test in VM First**: Test major updates in a virtual machine
6. **Document Custom Configurations**: Keep track of any manual configuration changes

## Security Considerations

1. **Verify Package Sources**: Only install from trusted sources
2. **Review Package Scripts**: Check installation scripts for suspicious content
3. **Use Antivirus**: Keep Windows Defender or antivirus active
4. **Limited Privileges**: Run Chocolatey with minimal required privileges
5. **Audit Installations**: Regularly review installed packages
   ```powershell
   choco list --local-only
   ```

## Additional Resources

- [Chocolatey Documentation](https://docs.chocolatey.org/)
- [Chocolatey Community Repository](https://community.chocolatey.org/packages)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/)
- [Docker Desktop Documentation](https://docs.docker.com/desktop/windows/)
- [OpenJDK Documentation](https://openjdk.org/projects/jdk/17/)

## Summary

This configuration provides a complete, production-ready development environment for Windows 11 with:
- Modern package management via Chocolatey
- Full Node.js/JavaScript development stack
- Complete Java development environment
- Docker containerization support
- Essential development tools and utilities

The setup is fully automated, idempotent, and can be customized based on specific needs. Regular maintenance through Chocolatey ensures all tools stay up-to-date with minimal effort.