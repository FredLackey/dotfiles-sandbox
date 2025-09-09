#!/usr/bin/env powershell
# Windows Development Environment Setup Script
# Completely headless installation of Chocolatey and development tools
# For Node.js, JavaScript, Java, C#, and Docker development
# 
# This script is idempotent - it can be run multiple times safely
# No user intervention required during execution

param(
    [switch]$SkipDocker = $false,
    [switch]$SkipDatabases = $false,
    [switch]$Minimal = $false,
    [switch]$Force = $false
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$InformationPreference = "Continue"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color -NoNewline
    Write-Host
}

# Function to test if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to test if a command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# Function to install Chocolatey if not present
function Install-Chocolatey {
    if (Test-CommandExists "choco") {
        Write-ColorOutput "Chocolatey is already installed (version: $(choco --version))" "Green"
        return $true
    }

    Write-ColorOutput "Installing Chocolatey..." "Yellow"
    
    try {
        # Set execution policy for this process
        Set-ExecutionPolicy Bypass -Scope Process -Force
        
        # Set TLS 1.2 for secure connections
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        
        # Download and execute Chocolatey install script
        $installScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        Invoke-Expression $installScript
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verify installation
        if (Test-CommandExists "choco") {
            Write-ColorOutput "Chocolatey installed successfully" "Green"
            return $true
        } else {
            throw "Chocolatey installation verification failed"
        }
    } catch {
        Write-ColorOutput "Failed to install Chocolatey: $_" "Red"
        return $false
    }
}

# Function to configure Chocolatey for headless operation
function Configure-Chocolatey {
    Write-ColorOutput "Configuring Chocolatey for headless operation..." "Cyan"
    
    # Enable global confirmation to avoid prompts
    & choco feature enable -n allowGlobalConfirmation -y 2>&1 | Out-Null
    
    # Set longer timeout for large packages
    & choco config set commandExecutionTimeoutSeconds 14400 -y 2>&1 | Out-Null
    
    # Set cache location
    & choco config set cacheLocation "$env:ProgramData\chocolatey\cache" -y 2>&1 | Out-Null
    
    # Disable progress to speed up downloads
    & choco feature disable -n showDownloadProgress -y 2>&1 | Out-Null
    
    Write-ColorOutput "Chocolatey configured for headless operation" "Green"
}

# Function to install a package if not already installed
function Install-ChocoPackage {
    param(
        [string]$PackageName,
        [string]$Version = "",
        [bool]$ForceReinstall = $false
    )
    
    # Check if package is already installed
    $installed = & choco list --local-only --exact $PackageName 2>&1
    $isInstalled = $installed -match "$PackageName"
    
    if ($isInstalled -and -not $ForceReinstall) {
        Write-ColorOutput "   $PackageName is already installed" "DarkGray"
        return $true
    }
    
    try {
        Write-ColorOutput "  Installing $PackageName..." "Yellow"
        
        if ($Version) {
            & choco install $PackageName --version $Version -y --no-progress --limitoutput 2>&1 | Out-Null
        } else {
            & choco install $PackageName -y --no-progress --limitoutput 2>&1 | Out-Null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "   $PackageName installed successfully" "Green"
            return $true
        } else {
            Write-ColorOutput "   $PackageName installation failed with exit code $LASTEXITCODE" "Red"
            return $false
        }
    } catch {
        Write-ColorOutput "   Failed to install $PackageName: $_" "Red"
        return $false
    }
}

# Function to install multiple packages
function Install-PackageGroup {
    param(
        [string]$GroupName,
        [array]$Packages
    )
    
    Write-ColorOutput "`nInstalling $GroupName..." "Cyan"
    
    $success = 0
    $failed = 0
    
    foreach ($package in $Packages) {
        if (Install-ChocoPackage -PackageName $package -ForceReinstall $Force) {
            $success++
        } else {
            $failed++
        }
    }
    
    Write-ColorOutput "$GroupName: $success succeeded, $failed failed" "Cyan"
}

# Function to verify installation
function Test-Installation {
    param(
        [string]$Command,
        [string]$DisplayName,
        [string]$VersionArg = "--version"
    )
    
    if (Test-CommandExists $Command) {
        try {
            $version = & $Command $VersionArg 2>&1 | Select-Object -First 1
            Write-ColorOutput "   $DisplayName is installed: $version" "Green"
            return $true
        } catch {
            Write-ColorOutput "   $DisplayName is installed (version check failed)" "Yellow"
            return $true
        }
    } else {
        Write-ColorOutput "   $DisplayName is not installed" "Red"
        return $false
    }
}

# Main installation function
function Install-DevelopmentEnvironment {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Windows Development Environment Setup" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
    
    # Check Administrator privileges
    if (-not (Test-Administrator)) {
        Write-ColorOutput "ERROR: This script requires Administrator privileges." "Red"
        Write-ColorOutput "Please run PowerShell as Administrator and try again." "Yellow"
        exit 1
    }
    
    # Install and configure Chocolatey
    if (-not (Install-Chocolatey)) {
        Write-ColorOutput "Failed to install Chocolatey. Exiting." "Red"
        exit 1
    }
    
    Configure-Chocolatey
    
    # Define package groups
    $corePackages = @(
        'git',
        'vscode',
        '7zip',
        'microsoft-windows-terminal',
        'powershell-core'
    )
    
    $nodePackages = @(
        'nodejs-lts',
        'yarn',
        'pnpm',
        'typescript'
    )
    
    $javaPackages = @(
        'openjdk17',
        'maven',
        'gradle'
    )
    
    $dotnetPackages = @(
        'dotnet-sdk',
        'dotnet-runtime',
        'dotnetcore-sdk',
        'visualstudio2022-workload-netweb'
    )
    
    $dockerPackages = @(
        'docker-desktop'
    )
    
    $databasePackages = @(
        'mongodb',
        'postgresql',
        'dbeaver'
    )
    
    $utilityPackages = @(
        'curl',
        'wget',
        'jq',
        'make',
        'python',
        'gh',
        'postman',
        'insomnia-rest-api-client'
    )
    
    # Install package groups
    Install-PackageGroup -GroupName "Core Development Tools" -Packages $corePackages
    Install-PackageGroup -GroupName "Node.js Development Tools" -Packages $nodePackages
    
    if (-not $Minimal) {
        Install-PackageGroup -GroupName "Java Development Tools" -Packages $javaPackages
        Install-PackageGroup -GroupName ".NET/C# Development Tools" -Packages $dotnetPackages
        Install-PackageGroup -GroupName "Utility Tools" -Packages $utilityPackages
        
        if (-not $SkipDatabases) {
            Install-PackageGroup -GroupName "Database Tools" -Packages $databasePackages
        }
        
        if (-not $SkipDocker) {
            Install-PackageGroup -GroupName "Docker Tools" -Packages $dockerPackages
        }
    }
    
    # Refresh environment variables
    Write-ColorOutput "`nRefreshing environment variables..." "Yellow"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Verify installations
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Verifying Installations" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
    
    Test-Installation -Command "git" -DisplayName "Git"
    Test-Installation -Command "code" -DisplayName "VS Code"
    Test-Installation -Command "node" -DisplayName "Node.js"
    Test-Installation -Command "npm" -DisplayName "npm"
    Test-Installation -Command "yarn" -DisplayName "Yarn"
    Test-Installation -Command "pnpm" -DisplayName "pnpm"
    
    if (-not $Minimal) {
        Test-Installation -Command "java" -DisplayName "Java" -VersionArg "-version"
        Test-Installation -Command "mvn" -DisplayName "Maven"
        Test-Installation -Command "gradle" -DisplayName "Gradle"
        Test-Installation -Command "dotnet" -DisplayName ".NET SDK"
        Test-Installation -Command "python" -DisplayName "Python"
        Test-Installation -Command "gh" -DisplayName "GitHub CLI"
        
        if (-not $SkipDocker) {
            Test-Installation -Command "docker" -DisplayName "Docker"
        }
    }
    
    # Post-installation configuration
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Post-Installation Configuration" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
    
    # Configure Git (if not already configured)
    $gitUser = & git config --global user.name 2>&1
    if (-not $gitUser) {
        Write-ColorOutput "Git user configuration not found. Skipping Git config." "Yellow"
        Write-ColorOutput "Run the following commands to configure Git:" "Yellow"
        Write-ColorOutput "  git config --global user.name 'Your Name'" "DarkGray"
        Write-ColorOutput "  git config --global user.email 'your.email@example.com'" "DarkGray"
    } else {
        Write-ColorOutput "Git is already configured for user: $gitUser" "Green"
    }
    
    # Set default Git branch name
    & git config --global init.defaultBranch main 2>&1 | Out-Null
    
    # Configure npm registry (ensure it's set to public registry)
    & npm config set registry https://registry.npmjs.org/ 2>&1 | Out-Null
    Write-ColorOutput "npm registry configured" "Green"
    
    # Final summary
    Write-ColorOutput "`n========================================" "Green"
    Write-ColorOutput "Installation Complete!" "Green"
    Write-ColorOutput "========================================`n" "Green"
    
    if (-not $SkipDocker) {
        Write-ColorOutput "IMPORTANT: Docker Desktop requires a system restart." "Yellow"
        Write-ColorOutput "Please restart your computer to complete Docker setup." "Yellow"
    }
    
    Write-ColorOutput "`nDevelopment environment is ready!" "Green"
    Write-ColorOutput "You may need to restart your terminal for all PATH changes to take effect." "Cyan"
    
    # Create a summary file
    $summaryPath = "$env:USERPROFILE\Desktop\DevEnvironmentSetup.txt"
    $summary = @"
Windows Development Environment Setup Summary
=============================================
Date: $(Get-Date)

Installed Components:
- Chocolatey Package Manager
- Git Version Control
- Visual Studio Code
- Node.js LTS with npm
- Yarn Package Manager
- pnpm Package Manager
$(if (-not $Minimal) {@"

- Java Development Kit (OpenJDK 17)
- Maven Build Tool
- Gradle Build Tool
- .NET SDK
- Python
- GitHub CLI
"@})
$(if (-not $SkipDocker -and -not $Minimal) {@"

- Docker Desktop
"@})
$(if (-not $SkipDatabases -and -not $Minimal) {@"

- MongoDB
- PostgreSQL
- DBeaver
"@})

Next Steps:
1. Restart your computer (required for Docker Desktop)
2. Configure Git with your name and email
3. Sign in to Docker Desktop (optional)
4. Open VS Code and install your preferred extensions

For updates, run:
  choco upgrade all -y

"@
    
    $summary | Out-File -FilePath $summaryPath -Encoding UTF8
    Write-ColorOutput "`nSetup summary saved to: $summaryPath" "Cyan"
}

# Execute main function
try {
    Install-DevelopmentEnvironment
    exit 0
} catch {
    Write-ColorOutput "`nERROR: An unexpected error occurred:" "Red"
    Write-ColorOutput $_.Exception.Message "Red"
    Write-ColorOutput "`nStack Trace:" "DarkGray"
    Write-ColorOutput $_.ScriptStackTrace "DarkGray"
    exit 1
}