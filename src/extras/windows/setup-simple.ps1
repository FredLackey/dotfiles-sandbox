#!/usr/bin/env powershell
# Simplified Windows Development Environment Setup Script
# This version avoids complex string interpolation

param(
    [switch]$SkipDocker = $false,
    [switch]$SkipDatabases = $false,
    [switch]$Minimal = $false,
    [switch]$Force = $false
)

# Script configuration
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Simple output functions
function WriteError([string]$msg) { Write-Host "   [X] $msg" -ForegroundColor Red }
function WriteSuccess([string]$msg) { Write-Host "   [OK] $msg" -ForegroundColor Green }
function WriteInfo([string]$msg) { Write-Host "   [i] $msg" -ForegroundColor Cyan }
function WriteWarning([string]$msg) { Write-Host "   [!] $msg" -ForegroundColor Yellow }
function WriteTitle([string]$msg) { 
    Write-Host ""
    Write-Host "   $msg" -ForegroundColor Cyan
    Write-Host ""
}

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    WriteError "This script requires Administrator privileges"
    WriteInfo "Please run PowerShell as Administrator"
    return
}

WriteTitle "Windows Development Environment Setup"
Write-Host "   Version: 1.0.0"
Write-Host "   Target: Windows 11 / Windows 10 (2004+)"
Write-Host ""

# Check .NET Framework
WriteInfo "Checking prerequisites..."
$release = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction SilentlyContinue
if ($release -and $release.Release -ge 528040) {
    WriteSuccess ".NET Framework 4.8 or later is installed"
} else {
    WriteWarning ".NET Framework 4.8 is required but not installed"
}

# Install Chocolatey
WriteTitle "Installing Chocolatey"
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $v = choco --version
    WriteSuccess "Chocolatey is already installed (version $v)"
} else {
    WriteInfo "Installing Chocolatey..."
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $url = 'https://community.chocolatey.org/install.ps1'
        $wc = New-Object System.Net.WebClient
        $script = $wc.DownloadString($url)
        Invoke-Expression $script | Out-Null
        
        $env:ChocolateyInstall = [System.Environment]::GetEnvironmentVariable('ChocolateyInstall','Machine')
        if (-not $env:ChocolateyInstall) {
            $env:ChocolateyInstall = "$env:ProgramData\chocolatey"
        }
        
        $env:Path = "$env:ChocolateyInstall\bin;" + $env:Path
        
        WriteSuccess "Chocolatey installed successfully"
    } catch {
        WriteError "Failed to install Chocolatey"
        WriteInfo "Please install manually from https://chocolatey.org"
        return
    }
}

# Configure Chocolatey
WriteInfo "Configuring Chocolatey..."
choco feature enable -n allowGlobalConfirmation -y 2>&1 | Out-Null
choco config set commandExecutionTimeoutSeconds 14400 2>&1 | Out-Null
WriteSuccess "Chocolatey configured"

# Function to install package
function InstallPackage([string]$name, [string]$displayName) {
    if (-not $displayName) { $displayName = $name }
    
    # Check if already installed via choco
    $list = choco list --local-only 2>&1
    if ($list -match $name) {
        WriteSuccess "$displayName is already installed"
        return
    }
    
    WriteInfo "Installing $displayName..."
    $result = choco install $name -y --no-progress --ignore-checksums 2>&1
    if ($LASTEXITCODE -eq 0) {
        WriteSuccess "$displayName installed"
    } else {
        WriteError "Failed to install $displayName"
    }
}

# Install Core Tools
WriteTitle "Core Development Tools"
InstallPackage "git" "Git"
InstallPackage "vscode" "Visual Studio Code"
InstallPackage "7zip" "7-Zip"
InstallPackage "powershell-core" "PowerShell Core"

# Windows Terminal special check
$wt = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
if ($wt) {
    WriteSuccess "Windows Terminal is already installed"
} else {
    InstallPackage "microsoft-windows-terminal" "Windows Terminal"
}

if (-not $Minimal) {
    # Node.js Tools
    WriteTitle "Node.js Development Stack"
    InstallPackage "nodejs-lts" "Node.js LTS"
    InstallPackage "yarn" "Yarn"
    InstallPackage "pnpm" "pnpm"
    
    # TypeScript via npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        WriteInfo "Installing TypeScript..."
        npm install -g typescript 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            WriteSuccess "TypeScript installed"
        } else {
            WriteError "TypeScript installation failed"
        }
    }
    
    # Java Tools
    WriteTitle "Java Development Stack"
    InstallPackage "openjdk17" "OpenJDK 17"
    InstallPackage "maven" "Maven"
    InstallPackage "gradle" "Gradle"
    InstallPackage "intellijidea-ultimate" "IntelliJ IDEA Ultimate"
    
    # .NET Tools
    WriteTitle ".NET Development Stack"
    InstallPackage "dotnet-sdk" ".NET SDK"
    
    # Additional Tools
    WriteTitle "Additional Utilities"
    InstallPackage "curl" "cURL"
    InstallPackage "wget" "wget"
    InstallPackage "jq" "jq"
    InstallPackage "make" "Make"
    InstallPackage "python" "Python"
    InstallPackage "gh" "GitHub CLI"
    
    if (-not $SkipDocker) {
        WriteTitle "Container Tools"
        InstallPackage "docker-desktop" "Docker Desktop"
    }
    
    if (-not $SkipDatabases) {
        WriteTitle "Database Tools"
        InstallPackage "mongodb" "MongoDB"
        InstallPackage "postgresql" "PostgreSQL"
        InstallPackage "dbeaver" "DBeaver"
    }
    
    # API Tools
    WriteTitle "API Development Tools"
    InstallPackage "postman" "Postman"
    InstallPackage "insomnia-rest-api-client" "Insomnia"
}

# Post-installation
WriteTitle "Post-Installation Configuration"

# Configure Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global init.defaultBranch main 2>&1 | Out-Null
    WriteSuccess "Git configured with default branch 'main'"
}

# Configure npm
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm config set registry https://registry.npmjs.org/ 2>&1 | Out-Null
    WriteSuccess "npm configured with public registry"
}

# Final message
WriteTitle "Setup Complete!"
WriteInfo "Next Steps:"
Write-Host "     1. Restart your computer (required for Docker Desktop)"
Write-Host "     2. Configure Git with your identity:"
Write-Host "        git config --global user.name 'Your Name'"
Write-Host "        git config --global user.email 'your.email@example.com'"
Write-Host "     3. Sign in to Docker Desktop (optional)"
Write-Host "     4. Install VS Code extensions"
Write-Host ""
WriteSuccess "Development environment setup complete!"
Write-Host ""