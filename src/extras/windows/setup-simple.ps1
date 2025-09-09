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

# Function to check if package is installed
function IsPackageInstalled([string]$name) {
    # Check if already installed via choco
    $list = choco list --local-only 2>&1 | Out-String
    if ($list -match $name) {
        return $true
    }
    
    # Check if installed on system
    switch ($name) {
        "git" { return (Get-Command git -ErrorAction SilentlyContinue) -ne $null }
        "vscode" { return (Get-Command code -ErrorAction SilentlyContinue) -ne $null }
        "docker-desktop" { return (Get-Command docker -ErrorAction SilentlyContinue) -ne $null }
        "python" { return (Get-Command python -ErrorAction SilentlyContinue) -ne $null }
        "nodejs-lts" { return (Get-Command node -ErrorAction SilentlyContinue) -ne $null }
        "yarn" { return (Get-Command yarn -ErrorAction SilentlyContinue) -ne $null }
        "pnpm" { return (Get-Command pnpm -ErrorAction SilentlyContinue) -ne $null }
        "curl" { return (Get-Command curl -ErrorAction SilentlyContinue) -ne $null }
        "wget" { return (Get-Command wget -ErrorAction SilentlyContinue) -ne $null }
        "jq" { return (Get-Command jq -ErrorAction SilentlyContinue) -ne $null }
        "make" { return (Get-Command make -ErrorAction SilentlyContinue) -ne $null }
        "gh" { return (Get-Command gh -ErrorAction SilentlyContinue) -ne $null }
        "openjdk17" { return (Get-Command java -ErrorAction SilentlyContinue) -ne $null }
        "maven" { return (Get-Command mvn -ErrorAction SilentlyContinue) -ne $null }
        "gradle" { return (Get-Command gradle -ErrorAction SilentlyContinue) -ne $null }
        "dotnet-sdk" { return (Get-Command dotnet -ErrorAction SilentlyContinue) -ne $null }
        "7zip" { return (Test-Path "$env:ProgramFiles\7-Zip\7z.exe") -or (Get-Command 7z -ErrorAction SilentlyContinue) -ne $null }
        "powershell-core" { return (Get-Command pwsh -ErrorAction SilentlyContinue) -ne $null }
        "microsoft-windows-terminal" { 
            return (Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue) -ne $null
        }
        "mongodb" { return (Get-Command mongod -ErrorAction SilentlyContinue) -ne $null }
        "postgresql" { return (Get-Command psql -ErrorAction SilentlyContinue) -ne $null }
        "dbeaver" { return (Test-Path "$env:ProgramFiles\DBeaver\dbeaver.exe") }
        "postman" { return (Test-Path "$env:LocalAppData\Postman\Postman.exe") }
        "insomnia-rest-api-client" { return (Test-Path "$env:LocalAppData\Insomnia\Insomnia.exe") }
        default { return $false }
    }
}

# Function to install package
function InstallPackage([string]$name, [string]$displayName) {
    if (-not $displayName) { $displayName = $name }
    
    # Check if already installed
    if (-not $Force -and (IsPackageInstalled $name)) {
        WriteSuccess "$displayName is already installed"
        return
    }
    
    WriteInfo "Installing $displayName..."
    
    $retryCount = 0
    $maxRetries = 2
    $installed = $false
    
    while ($retryCount -lt $maxRetries -and -not $installed) {
        if ($retryCount -gt 0) {
            WriteInfo "Retry attempt $retryCount for $displayName..."
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
                return
            }
            Start-Sleep -Seconds 2
        }
    }
}

# Install Core Tools
WriteTitle "Core Development Tools"
InstallPackage "git" "Git"
InstallPackage "vscode" "Visual Studio Code"
InstallPackage "7zip" "7-Zip"
InstallPackage "powershell-core" "PowerShell Core"

# Windows Terminal special check
if (-not (Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue)) {
    InstallPackage "microsoft-windows-terminal" "Windows Terminal"
} else {
    WriteSuccess "Windows Terminal is already installed"
}

if (-not $Minimal) {
    # Node.js Tools
    WriteTitle "Node.js Development Stack"
    InstallPackage "nodejs-lts" "Node.js LTS"
    InstallPackage "yarn" "Yarn"
    InstallPackage "pnpm" "pnpm"
    
    # TypeScript via npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        if (npm list -g typescript 2>&1 | Select-String "typescript@") {
            WriteSuccess "TypeScript is already installed"
        } else {
            WriteInfo "Installing TypeScript..."
            npm install -g typescript 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                WriteSuccess "TypeScript installed"
            } else {
                npm install -g typescript --force 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    WriteSuccess "TypeScript installed (forced)"
                } else {
                    WriteError "TypeScript installation failed"
                }
            }
        }
    }
    
    # Java Tools
    WriteTitle "Java Development Stack"
    InstallPackage "openjdk17" "OpenJDK 17"
    InstallPackage "maven" "Maven"
    InstallPackage "gradle" "Gradle"
    
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
        # Check if already installed
        $ideaInstalled = $false
        $ideaPaths = @(
            "$env:ProgramFiles\JetBrains\IntelliJ IDEA*",
            "${env:ProgramFiles(x86)}\JetBrains\IntelliJ IDEA*",
            "$env:LocalAppData\JetBrains\Toolbox\apps\IDEA-U*"
        )
        
        foreach ($path in $ideaPaths) {
            if (Test-Path $path) {
                $ideaInstalled = $true
                break
            }
        }
        
        if ($ideaInstalled) {
            WriteSuccess "IntelliJ IDEA is already installed"
        } else {
            InstallPackage "intellijidea-ultimate" "IntelliJ IDEA Ultimate"
            
            # If Ultimate fails, try Community
            if (-not (IsPackageInstalled "intellijidea-ultimate")) {
                WriteWarning "IntelliJ IDEA Ultimate installation failed, trying Community Edition..."
                InstallPackage "intellijidea-community" "IntelliJ IDEA Community"
            }
        }
    }
    
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