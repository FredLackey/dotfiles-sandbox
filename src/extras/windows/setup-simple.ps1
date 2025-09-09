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

# Function to install package with retry
function InstallPackage([string]$name, [string]$displayName, [int]$maxRetries = 2) {
    if (-not $displayName) { $displayName = $name }
    
    # Check if already installed via choco
    $list = choco list --local-only 2>&1 | Out-String
    if ($list -match $name) {
        WriteSuccess "$displayName is already installed via Chocolatey"
        return $true
    }
    
    # Special checks for commonly pre-installed software
    switch ($name) {
        "git" {
            if (Get-Command git -ErrorAction SilentlyContinue) {
                WriteSuccess "Git is already installed on system"
                return $true
            }
        }
        "vscode" {
            if (Get-Command code -ErrorAction SilentlyContinue) {
                WriteSuccess "Visual Studio Code is already installed on system"
                return $true
            }
        }
        "docker-desktop" {
            if (Get-Command docker -ErrorAction SilentlyContinue) {
                WriteSuccess "Docker Desktop is already installed on system"
                return $true
            }
        }
        "python" {
            if (Get-Command python -ErrorAction SilentlyContinue) {
                WriteSuccess "Python is already installed on system"
                return $true
            }
        }
        "nodejs-lts" {
            if (Get-Command node -ErrorAction SilentlyContinue) {
                WriteSuccess "Node.js is already installed on system"
                return $true
            }
        }
    }
    
    $retryCount = 0
    $installed = $false
    
    while ($retryCount -lt $maxRetries -and -not $installed) {
        if ($retryCount -gt 0) {
            WriteInfo "Retry attempt $retryCount for $displayName..."
        } else {
            WriteInfo "Installing $displayName..."
        }
        
        $result = choco install $name -y --no-progress --ignore-checksums --force 2>&1 | Out-String
        
        # Check various success conditions
        $successCodes = @(0, 3010, 1641)
        if ($LASTEXITCODE -in $successCodes) {
            WriteSuccess "$displayName installed"
            $installed = $true
        } elseif ($result -match "already installed") {
            WriteSuccess "$displayName was already installed"
            $installed = $true
        } else {
            $retryCount++
            if ($retryCount -ge $maxRetries) {
                WriteError "Failed to install $displayName after $maxRetries attempts"
                return $false
            }
            Start-Sleep -Seconds 2
        }
    }
    return $installed
}

# Install Core Tools
WriteTitle "Core Development Tools"
$null = InstallPackage "git" "Git"
$null = InstallPackage "vscode" "Visual Studio Code"
$null = InstallPackage "7zip" "7-Zip"
$null = InstallPackage "powershell-core" "PowerShell Core"

# Windows Terminal special check
$wt = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
if ($wt) {
    WriteSuccess "Windows Terminal is already installed"
} else {
    $null = InstallPackage "microsoft-windows-terminal" "Windows Terminal"
}

if (-not $Minimal) {
    # Node.js Tools
    WriteTitle "Node.js Development Stack"
    $null = InstallPackage "nodejs-lts" "Node.js LTS"
    $null = InstallPackage "yarn" "Yarn"
    $null = InstallPackage "pnpm" "pnpm"
    
    # TypeScript via npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        WriteInfo "Installing TypeScript..."
        npm install -g typescript 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            WriteSuccess "TypeScript installed"
        } else {
            # Retry with force
            npm install -g typescript --force 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                WriteSuccess "TypeScript installed (forced)"
            } else {
                WriteError "TypeScript installation failed"
            }
        }
    }
    
    # Java Tools
    WriteTitle "Java Development Stack"
    $null = InstallPackage "openjdk17" "OpenJDK 17"
    $null = InstallPackage "maven" "Maven"
    $null = InstallPackage "gradle" "Gradle"
    
    # IntelliJ IDEA Ultimate - Check architecture first
    WriteInfo "Checking system architecture for IntelliJ IDEA compatibility..."
    
    # Check if x86 or x64 architecture (IntelliJ requires x86/x64)
    $arch = $env:PROCESSOR_ARCHITECTURE
    $arch64 = $env:PROCESSOR_ARCHITEW6432
    
    $isX86Compatible = ($arch -eq "AMD64") -or ($arch -eq "x86") -or ($arch64 -eq "AMD64")
    
    if (-not $isX86Compatible) {
        WriteWarning "IntelliJ IDEA requires x86/x64 architecture. Current architecture: $arch"
        WriteInfo "Skipping IntelliJ IDEA installation on ARM/other architecture"
    } else {
        WriteInfo "Installing IntelliJ IDEA Ultimate..."
        
        # First try the standard package
        $ideaInstalled = InstallPackage "intellijidea-ultimate" "IntelliJ IDEA Ultimate" 3
        
        # If that fails, try alternative approaches
        if (-not $ideaInstalled) {
            WriteInfo "Trying alternative installation for IntelliJ IDEA Ultimate..."
            
            # Try with different parameters
            $result = choco install intellijidea-ultimate -y --ignore-checksums --allow-empty-checksums --force 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                WriteSuccess "IntelliJ IDEA Ultimate installed via alternative method"
            } else {
                # Try the community edition as fallback
                WriteWarning "IntelliJ IDEA Ultimate installation failed, installing Community Edition instead..."
                $communityResult = choco install intellijidea-community -y --no-progress --ignore-checksums --force 2>&1 | Out-String
                if ($LASTEXITCODE -eq 0 -or $communityResult -match "already installed") {
                    WriteSuccess "IntelliJ IDEA Community Edition installed as fallback"
                    WriteInfo "You can upgrade to Ultimate Edition later if needed"
                } else {
                    WriteError "Could not install any version of IntelliJ IDEA"
                }
            }
        }
    }
    
    # .NET Tools
    WriteTitle ".NET Development Stack"
    $null = InstallPackage "dotnet-sdk" ".NET SDK"
    
    # Additional Tools
    WriteTitle "Additional Utilities"
    $null = InstallPackage "curl" "cURL"
    $null = InstallPackage "wget" "wget"
    $null = InstallPackage "jq" "jq"
    $null = InstallPackage "make" "Make"
    $null = InstallPackage "python" "Python"
    $null = InstallPackage "gh" "GitHub CLI"
    
    if (-not $SkipDocker) {
        WriteTitle "Container Tools"
        
        # Check if Docker Desktop is already installed
        $dockerInstalled = $false
        
        # Check common Docker Desktop installation indicators
        if (Get-Command docker -ErrorAction SilentlyContinue) {
            $dockerInstalled = $true
        } elseif (Test-Path "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe") {
            $dockerInstalled = $true
        } elseif (Test-Path "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe") {
            $dockerInstalled = $true
        } elseif (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*Docker Desktop*" }) {
            $dockerInstalled = $true
        }
        
        if ($dockerInstalled) {
            WriteSuccess "Docker Desktop is already installed"
        } else {
            $null = InstallPackage "docker-desktop" "Docker Desktop"
        }
    }
    
    if (-not $SkipDatabases) {
        WriteTitle "Database Tools"
        $null = InstallPackage "mongodb" "MongoDB"
        $null = InstallPackage "postgresql" "PostgreSQL"
        $null = InstallPackage "dbeaver" "DBeaver"
    }
    
    # API Tools
    WriteTitle "API Development Tools"
    $null = InstallPackage "postman" "Postman"
    $null = InstallPackage "insomnia-rest-api-client" "Insomnia"
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

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

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