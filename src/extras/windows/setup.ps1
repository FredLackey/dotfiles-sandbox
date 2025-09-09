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
$ErrorActionPreference = "Continue"  # Continue on errors instead of stopping
$ProgressPreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# Output formatting functions (matching Ubuntu style)
function print_error {
    param([string]$Message)
    Write-Host ("   [✖] " + $Message) -ForegroundColor Red
}

function print_success {
    param([string]$Message)
    Write-Host ("   [✔] " + $Message) -ForegroundColor Green
}

function print_info {
    param([string]$Message)
    Write-Host ("   [i] " + $Message) -ForegroundColor Cyan
}

function print_warning {
    param([string]$Message)  
    Write-Host ("   [!] " + $Message) -ForegroundColor Yellow
}

function print_title {
    param([string]$Message)
    Write-Host ""
    Write-Host ("   " + $Message) -ForegroundColor Cyan
    Write-Host ""
}

function print_in_progress {
    param([string]$Message)
    Write-Host ("   [⋯] " + $Message) -NoNewline
}

function clear_line() {
    Write-Host "`r" -NoNewline
    Write-Host (" " * 80) -NoNewline
    Write-Host "`r" -NoNewline
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

# Main function
function main() {
    # Welcome message
    Write-Host ""
    Write-Host "   Windows Development Environment Setup" -ForegroundColor Cyan
    Write-Host "   ====================================="
    Write-Host "   Version: 1.0.0"
    Write-Host "   Target: Windows 11 / Windows 10 (2004+)"
    Write-Host ""
    print_info "Installing development tools for:"
    Write-Host "     • Node.js & JavaScript Development"
    Write-Host "     • Java Development (OpenJDK)"
    Write-Host "     • .NET & C# Development"
    Write-Host "     • Container Development (Docker)"
    Write-Host "     • Database Management"
    Write-Host "     • API Development & Testing"
    Write-Host ""

    # Installation flags
    if ($Minimal -or $SkipDocker -or $SkipDatabases -or $Force) {
        print_info "Installation parameters:"
        if ($Minimal) {
            print_warning "Minimal installation (essential tools only)"
        }
        if ($SkipDocker) {
            print_warning "Docker Desktop will be skipped"
        }
        if ($SkipDatabases) {
            print_warning "Database tools will be skipped"
        }
        if ($Force) {
            print_warning "Force reinstall mode enabled"
        }
        Write-Host ""
    }

    # Check Administrator privileges
    if (-not (Test-Administrator)) {
        print_error "This script requires Administrator privileges"
        print_info "Please run PowerShell as Administrator and try again"
        return
    }

    # Check for .NET Framework 4.8
    print_info "Checking prerequisites..."
    $release = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction SilentlyContinue
    if ($release -and $release.Release -ge 528040) {
        print_success ".NET Framework 4.8 or later is installed"
    } else {
        print_warning ".NET Framework 4.8 is required but not installed"
        Write-Host "     Please install from: https://dotnet.microsoft.com/download/dotnet-framework/net48" -ForegroundColor Cyan
    }
    Write-Host ""

    # Install Chocolatey if not present
    print_title "Chocolatey Package Manager"
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $chocoVersion = (choco --version)
        print_success ("Chocolatey v" + $chocoVersion + " is already installed")
    } else {
        print_in_progress "Installing Chocolatey..."
        try {
            # Enable TLS 1.2
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            
            # Download and install Chocolatey
            $installScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
            Invoke-Expression $installScript | Out-Null
            
            # Refresh environment
            $env:ChocolateyInstall = [System.Environment]::GetEnvironmentVariable('ChocolateyInstall','Machine')
            if (-not $env:ChocolateyInstall) {
                $env:ChocolateyInstall = $env:ProgramData + "\chocolatey"
            }
            $modulePath = $env:ChocolateyInstall + "\helpers\chocolateyProfile.psm1"
            Import-Module $modulePath -Force
            Update-SessionEnvironment
            
            clear_line
            print_success "Chocolatey installed successfully"
        } catch {
            clear_line
            print_error ("Failed to install Chocolatey: " + $_)
            print_info "Please install Chocolatey manually from https://chocolatey.org"
            return
        }
    }

    # Configure Chocolatey for silent operation
    print_in_progress "Configuring Chocolatey..."
    try {
        choco feature enable -n allowGlobalConfirmation -y 2>&1 | Out-Null
        choco config set commandExecutionTimeoutSeconds 14400 2>&1 | Out-Null
        choco config set webRequestTimeoutSeconds 180 2>&1 | Out-Null
        $cachePath = $env:TEMP + "\chocolatey"
        choco config set cacheLocation $cachePath 2>&1 | Out-Null
        clear_line
        print_success "Chocolatey configured for automated installation"
    } catch {
        clear_line
        print_warning "Could not configure Chocolatey settings"
    }

    # Package detection commands
    $packageChecks = @{
        'git' = 'git --version'
        'vscode' = 'code --version'
        '7zip' = '7z'
        'powershell-core' = 'pwsh --version'
        'nodejs-lts' = 'node --version'
        'yarn' = 'yarn --version'
        'pnpm' = 'pnpm --version'
        'openjdk17' = 'java -version'
        'maven' = 'mvn --version'
        'gradle' = 'gradle --version'
        'intellijidea-ultimate' = 'if (Test-Path "$env:ProgramFiles\JetBrains") { @(Get-ChildItem -Path "$env:ProgramFiles\JetBrains" -Filter "IntelliJ IDEA*" -ErrorAction SilentlyContinue).Count -gt 0 } else { $false }'
        'dotnet-sdk' = 'dotnet --version'
        'docker-desktop' = 'docker --version'
        'mongodb' = 'mongod --version'
        'postgresql' = 'psql --version'
        'dbeaver' = 'Test-Path ($env:ProgramFiles + "\DBeaver\dbeaver.exe")'
        'curl' = 'curl --version'
        'wget' = 'wget --version'
        'jq' = 'jq --version'
        'make' = 'make --version'
        'python' = 'python --version'
        'gh' = 'gh --version'
        'postman' = 'Test-Path ($env:LocalAppData + "\Postman\Postman.exe")'
        'insomnia-rest-api-client' = 'Test-Path ($env:LocalAppData + "\Insomnia\Insomnia.exe")'
    }

    # Function to install a package if not already present
    function Install-PackageIfNotPresent {
        param(
            [string]$PackageName,
            [string]$DisplayName,
            [string]$Category,
            [string]$DetectionCommand = "",
            [string]$Version = ""
        )
        
        # Use display name if provided, otherwise use package name
        $name = if ($DisplayName) { $DisplayName } else { $PackageName }
        
        # Check if already installed using detection command
        $isInstalled = $false
        if ($DetectionCommand) {
            try {
                $result = Invoke-Expression $DetectionCommand 2>$null
                if ($result) {
                    $isInstalled = $true
                }
            } catch {
                $isInstalled = $false
            }
        }
        
        if ($isInstalled -and -not $Force) {
            print_success ($name + " is already installed")
            $global:installedCount++
            return $true
        }
        
        # Try to install
        print_in_progress ("Installing " + $name + "...")
        
        try {
            $installCmd = "choco install $PackageName -y --no-progress --ignore-checksums"
            if ($Version) {
                $installCmd += " --version=$Version"
            }
            if ($Force) {
                $installCmd += " --force"
            }
            
            $output = Invoke-Expression $installCmd 2>&1
            
            # Check if installation was successful
            if ($LASTEXITCODE -eq 0 -or $output -match "already installed") {
                clear_line
                print_success ($name + " installed")
                $global:installedCount++
                return $true
            } else {
                clear_line
                print_error ($name + " installation failed")
                $global:failedPackages += $name
                return $false
            }
        } catch {
            clear_line
            print_error ($name + " installation error: " + $_)
            $global:failedPackages += $name
            return $false
        }
    }

    # Tracking variables
    $global:installedCount = 0
    $global:failedPackages = @()

    # Install Core Development Tools
    print_title "Core Development Tools"
    foreach ($pkg in @('git', 'vscode', '7zip', 'powershell-core')) {
        $displayName = switch ($pkg) {
            'git' { 'Git' }
            'vscode' { 'Visual Studio Code' }
            '7zip' { '7-Zip' }
            'powershell-core' { 'PowerShell Core' }
        }
        Install-PackageIfNotPresent -PackageName $pkg -DisplayName $displayName -DetectionCommand $packageChecks[$pkg]
    }

    # Special handling for Windows Terminal
    $wtInstalled = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
    $wtPath = $env:LocalAppData + "\Microsoft\WindowsApps\wt.exe"
    if (-not $wtInstalled -and -not (Test-Path $wtPath)) {
        Install-PackageIfNotPresent -PackageName 'microsoft-windows-terminal' -DisplayName 'Windows Terminal' -DetectionCommand 'wt'
    } else {
        print_success "Windows Terminal is already installed"
        $global:installedCount++
    }

    # Install Node.js Development Tools
    if (-not $Minimal) {
        print_title "Node.js Development Stack"
        foreach ($pkg in @('nodejs-lts', 'yarn', 'pnpm')) {
            $displayName = switch ($pkg) {
                'nodejs-lts' { 'Node.js LTS' }
                'yarn' { 'Yarn' }
                'pnpm' { 'pnpm' }
            }
            Install-PackageIfNotPresent -PackageName $pkg -DisplayName $displayName -DetectionCommand $packageChecks[$pkg]
        }

        # Install TypeScript globally via npm
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            print_in_progress "Installing TypeScript..."
            $output = npm install -g typescript 2>&1
            if ($LASTEXITCODE -eq 0) {
                clear_line
                print_success "TypeScript installed"
                $global:installedCount++
            } else {
                clear_line
                print_error "TypeScript installation failed"
                $global:failedPackages += "TypeScript"
            }
        }
    }

    # Install Java Development Tools
    if (-not $Minimal -and -not $SkipJava) {
        print_title "Java Development Stack"
        
        # Install basic Java tools
        foreach ($pkg in @('openjdk17', 'maven', 'gradle')) {
            $displayName = switch ($pkg) {
                'openjdk17' { 'OpenJDK 17' }
                'maven' { 'Maven' }
                'gradle' { 'Gradle' }
            }
            Install-PackageIfNotPresent -PackageName $pkg -DisplayName $displayName -DetectionCommand $packageChecks[$pkg]
        }
        
        # Check architecture before installing IntelliJ IDEA
        $arch = $env:PROCESSOR_ARCHITECTURE
        $arch64 = $env:PROCESSOR_ARCHITEW6432
        $isX86Compatible = ($arch -eq "AMD64") -or ($arch -eq "x86") -or ($arch64 -eq "AMD64")
        
        if (-not $isX86Compatible) {
            print_warning ("IntelliJ IDEA requires x86/x64 architecture. Current: " + $arch)
            print_info "Skipping IntelliJ IDEA installation on ARM/other architecture"
        } else {
            Install-PackageIfNotPresent -PackageName 'intellijidea-ultimate' -DisplayName 'IntelliJ IDEA Ultimate' -DetectionCommand $packageChecks['intellijidea-ultimate']
        }
    }

    # Install .NET Development Tools
    if (-not $Minimal -and -not $SkipDotNet) {
        print_title ".NET Development Stack"
        Install-PackageIfNotPresent -PackageName 'dotnet-sdk' -DisplayName '.NET SDK' -DetectionCommand $packageChecks['dotnet-sdk']
    }

    # Install Docker Desktop
    if (-not $SkipDocker -and -not $Minimal) {
        print_title "Container Tools"
        Install-PackageIfNotPresent -PackageName 'docker-desktop' -DisplayName 'Docker Desktop' -DetectionCommand $packageChecks['docker-desktop']
    }

    # Install Database Tools
    if (-not $SkipDatabases -and -not $Minimal) {
        print_title "Database Tools"
        foreach ($pkg in @('mongodb', 'postgresql', 'dbeaver')) {
            $displayName = switch ($pkg) {
                'mongodb' { 'MongoDB' }
                'postgresql' { 'PostgreSQL' }
                'dbeaver' { 'DBeaver' }
            }
            Install-PackageIfNotPresent -PackageName $pkg -DisplayName $displayName -DetectionCommand $packageChecks[$pkg]
        }
    }

    # Install API Development Tools
    if (-not $Minimal) {
        print_title "API Development Tools"
        foreach ($pkg in @('postman', 'insomnia-rest-api-client')) {
            $displayName = switch ($pkg) {
                'postman' { 'Postman' }
                'insomnia-rest-api-client' { 'Insomnia' }
            }
            Install-PackageIfNotPresent -PackageName $pkg -DisplayName $displayName -DetectionCommand $packageChecks[$pkg]
        }
    }

    # Install Additional Utilities
    if (-not $Minimal) {
        print_title "Additional Utilities"
        foreach ($pkg in @('curl', 'wget', 'jq', 'make', 'python', 'gh')) {
            $displayName = switch ($pkg) {
                'curl' { 'cURL' }
                'wget' { 'wget' }
                'jq' { 'jq' }
                'make' { 'Make' }
                'python' { 'Python' }
                'gh' { 'GitHub CLI' }
            }
            Install-PackageIfNotPresent -PackageName $pkg -DisplayName $displayName -DetectionCommand $packageChecks[$pkg]
        }
    }

    # Post-installation configuration
    print_title "Post-Installation Configuration"

    # Configure Git
    print_in_progress "Configuring Git..."
    try {
        git config --global init.defaultBranch main 2>&1 | Out-Null
        clear_line
        print_success "Git configured with default branch 'main'"
    } catch {
        clear_line
        print_warning "Could not configure Git"
    }

    # Configure npm registry
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        print_in_progress "Configuring npm..."
        try {
            npm config set registry https://registry.npmjs.org/ 2>&1 | Out-Null
            clear_line
            print_success "npm configured with public registry"
        } catch {
            clear_line
            print_warning "Could not configure npm"
        }
    }

    # Refresh environment variables
    print_in_progress "Refreshing environment variables..."
    try {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        clear_line
        print_success "Environment variables refreshed"
    } catch {
        clear_line
        print_warning "Could not refresh environment variables"
    }

    # Installation Summary
    print_title "Installation Summary"
    print_success ("Packages installed: " + $installedCount)
    if ($failedPackages.Count -gt 0) {
        $failedCount = $failedPackages.Count
        print_error ("Packages failed: " + $failedCount)
        Write-Host "   Failed packages:"
        foreach ($pkg in $failedPackages) {
            Write-Host ("     - " + $pkg) -ForegroundColor Red
        }
    }

    # Create summary file
    Write-Host ""
    print_in_progress "Creating summary file on Desktop..."
    $dateStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $summaryPath = $env:USERPROFILE + "\Desktop\DevEnvironmentSetup_" + $dateStamp + ".txt"
    try {
        # Build all the dynamic content first
        $currentDate = Get-Date
        $failedCount = $failedPackages.Count
        
        # Build components list
        $components = @()
        if (Get-Command choco -ErrorAction SilentlyContinue) { $components += "✔ Chocolatey Package Manager" } else { $components += "✖ Chocolatey Package Manager" }
        if (Get-Command git -ErrorAction SilentlyContinue) { $components += "✔ Git" } else { $components += "✖ Git" }
        if (Get-Command code -ErrorAction SilentlyContinue) { $components += "✔ Visual Studio Code" } else { $components += "✖ Visual Studio Code" }
        if (Get-Command node -ErrorAction SilentlyContinue) { $components += "✔ Node.js" } else { $components += "✖ Node.js" }
        if (Get-Command npm -ErrorAction SilentlyContinue) { $components += "✔ npm" } else { $components += "✖ npm" }
        if (Get-Command yarn -ErrorAction SilentlyContinue) { $components += "✔ Yarn" } else { $components += "✖ Yarn" }
        if (Get-Command pnpm -ErrorAction SilentlyContinue) { $components += "✔ pnpm" } else { $components += "✖ pnpm" }
        
        if (-not $Minimal) {
            if (Get-Command java -ErrorAction SilentlyContinue) { $components += "✔ Java (OpenJDK)" } else { $components += "✖ Java (OpenJDK)" }
            if (Get-Command mvn -ErrorAction SilentlyContinue) { $components += "✔ Maven" } else { $components += "✖ Maven" }
            if (Get-Command gradle -ErrorAction SilentlyContinue) { $components += "✔ Gradle" } else { $components += "✖ Gradle" }
            if (Get-Command dotnet -ErrorAction SilentlyContinue) { $components += "✔ .NET SDK" } else { $components += "✖ .NET SDK" }
            if (Get-Command python -ErrorAction SilentlyContinue) { $components += "✔ Python" } else { $components += "✖ Python" }
            if (Get-Command gh -ErrorAction SilentlyContinue) { $components += "✔ GitHub CLI" } else { $components += "✖ GitHub CLI" }
        }
        
        if (-not $SkipDocker -and -not $Minimal) {
            if (Get-Command docker -ErrorAction SilentlyContinue) { $components += "✔ Docker Desktop" } else { $components += "✖ Docker Desktop" }
        }
        
        if (-not $SkipDatabases -and -not $Minimal) {
            if (Get-Command mongod -ErrorAction SilentlyContinue) { $components += "✔ MongoDB" } else { $components += "✖ MongoDB" }
            if (Get-Command psql -ErrorAction SilentlyContinue) { $components += "✔ PostgreSQL" } else { $components += "✖ PostgreSQL" }
            $dbeaverPath = $env:ProgramFiles + "\DBeaver\dbeaver.exe"
            if (Test-Path $dbeaverPath) { $components += "✔ DBeaver" } else { $components += "✖ DBeaver" }
        }
        
        $componentsList = $components -join "`n"
        
        # Build failed packages section if needed
        $failedSection = ""
        if ($failedPackages.Count -gt 0) {
            $failedList = $failedPackages -join "`n"
            $failedSection = @"

Failed Packages:
----------------
$failedList
"@
        }
        
        # Now build the complete summary
        $summary = @"
Windows Development Environment Setup Summary
=============================================
Date: $currentDate
Machine: $env:COMPUTERNAME
User: $env:USERNAME

Installed Packages: $installedCount
Failed Packages: $failedCount

Installed Components:
---------------------
$componentsList
$failedSection

Next Steps:
-----------
1. Restart your computer (required for Docker Desktop)
2. Configure Git with your identity:
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
3. Sign in to Docker Desktop (optional)
4. Install VS Code extensions for your preferred languages

To update all packages:
   choco upgrade all -y

To check for outdated packages:
   choco outdated
"@
        $summary | Out-File -FilePath $summaryPath -Encoding UTF8
        clear_line
        print_success ("Summary saved to: " + $summaryPath)
    } catch {
        clear_line
        print_warning "Could not create summary file"
    }

    # Final instructions
    print_title "Setup Complete!"
    print_info "Next Steps:"
    Write-Host "     1. Restart your computer (required for Docker Desktop)"
    Write-Host "     2. Configure Git with your identity:"
    Write-Host "        git config --global user.name 'Your Name'"
    Write-Host "        git config --global user.email 'your.email@example.com'"
    Write-Host "     3. Sign in to Docker Desktop (optional)"
    Write-Host "     4. Install VS Code extensions for your preferred languages"
    Write-Host ""
    print_success "Installation log saved to Desktop"
    Write-Host ""
}

# Execute main function
main