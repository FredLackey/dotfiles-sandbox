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
        $chocoVersion = & choco --version 2>&1
        Write-ColorOutput "Chocolatey is already installed (version: $chocoVersion)" "Green"
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
        Invoke-Expression $installScript 2>&1 | Out-String | Write-Host
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:ChocolateyInstall = "$env:ProgramData\chocolatey"
        
        # Give the system a moment to register the new PATH
        Start-Sleep -Seconds 2
        
        # Try to refresh the choco command
        refreshenv 2>&1 | Out-Null
        
        # Verify installation
        if (Test-CommandExists "choco") {
            Write-ColorOutput "Chocolatey installed successfully" "Green"
            return $true
        } else {
            # Try one more time with direct path
            $chocoPath = "$env:ProgramData\chocolatey\bin\choco.exe"
            if (Test-Path $chocoPath) {
                $env:Path = "$env:ProgramData\chocolatey\bin;" + $env:Path
                Write-ColorOutput "Chocolatey installed successfully" "Green"
                return $true
            } else {
                throw "Chocolatey installation verification failed"
            }
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
    & choco feature enable -n allowGlobalConfirmation -y --limit-output 2>&1 | Out-Null
    
    # Set longer timeout for large packages
    & choco config set commandExecutionTimeoutSeconds 14400 -y --limit-output 2>&1 | Out-Null
    
    # Set cache location
    & choco config set cacheLocation "$env:ProgramData\chocolatey\cache" -y --limit-output 2>&1 | Out-Null
    
    # Disable progress to speed up downloads
    & choco feature disable -n showDownloadProgress -y --limit-output 2>&1 | Out-Null
    
    Write-ColorOutput "Chocolatey configured for headless operation" "Green"
}

# Function to check if a program exists on the system
function Test-ProgramInstalled {
    param(
        [string]$ProgramName,
        [string[]]$CheckCommands = @(),
        [string]$RegistryPath = ""
    )
    
    # Check common executable names if not specified
    if ($CheckCommands.Count -eq 0) {
        $CheckCommands = @($ProgramName, "$ProgramName.exe")
    }
    
    # Check if command exists in PATH
    foreach ($cmd in $CheckCommands) {
        if (Test-CommandExists $cmd) {
            return $true
        }
    }
    
    # Check in common installation directories
    $commonPaths = @(
        "$env:ProgramFiles\$ProgramName",
        "${env:ProgramFiles(x86)}\$ProgramName",
        "$env:LocalAppData\$ProgramName",
        "$env:ProgramData\$ProgramName"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check Windows Registry if path provided
    if ($RegistryPath) {
        if (Test-Path $RegistryPath) {
            return $true
        }
    }
    
    # Check via Get-Package (much faster than WMI)
    try {
        $package = Get-Package -Name "*$ProgramName*" -ErrorAction SilentlyContinue
        if ($package) {
            return $true
        }
    } catch {
        # Ignore errors from Get-Package
    }
    
    # Skip deep Program Files search to avoid hanging
    # Most programs should be found via PATH or Get-Package already
    
    return $false
}

# Function to install a package if not already installed
function Install-ChocoPackage {
    param(
        [string]$PackageName,
        [string]$Version = "",
        [bool]$ForceReinstall = $false,
        [string[]]$CheckCommands = @(),
        [string]$RegistryPath = ""
    )
    
    # First check if program is already installed on the system
    if (-not $ForceReinstall) {
        if (Test-ProgramInstalled -ProgramName $PackageName -CheckCommands $CheckCommands -RegistryPath $RegistryPath) {
            $msg = "  [OK] " + $PackageName + " is already installed on system"
            Write-ColorOutput $msg "DarkGray"
            return $true
        }
    }
    
    # Check if package is already installed via Chocolatey
    $installed = & choco list --local-only --exact $PackageName --limit-output 2>&1
    $isInstalled = $installed -match "$PackageName"
    
    if ($isInstalled -and -not $ForceReinstall) {
        $msg = "  [OK] " + $PackageName + " is already installed via Chocolatey"
        Write-ColorOutput $msg "DarkGray"
        return $true
    }
    
    try {
        $msg = "  Installing " + $PackageName + "..."
        Write-ColorOutput $msg "Yellow"
        
        if ($Version) {
            $chocoOutput = & choco install $PackageName --version $Version -y --no-progress --limit-output --ignore-checksums --ignore-package-exit-codes 2>&1
        } else {
            $chocoOutput = & choco install $PackageName -y --no-progress --limit-output --ignore-checksums --ignore-package-exit-codes 2>&1
        }
        
        # Check various success conditions
        $successCodes = @(0, 3010, 1641, 1605, 1614, 1641, 3010)
        $alreadyInstalled = $chocoOutput | Select-String -Pattern "already installed|nothing to do" -Quiet
        
        if ($LASTEXITCODE -in $successCodes -or $alreadyInstalled) {
            if ($LASTEXITCODE -eq 3010 -or $LASTEXITCODE -eq 1641) {
                $msg = "  [OK] " + $PackageName + " installed (restart required)"
                Write-ColorOutput $msg "Yellow"
            } elseif ($alreadyInstalled) {
                $msg = "  [OK] " + $PackageName + " was already installed"
                Write-ColorOutput $msg "DarkGray"
            } else {
                $msg = "  [OK] " + $PackageName + " installed successfully"
                Write-ColorOutput $msg "Green"
            }
            return $true
        } else {
            # Some packages return non-zero even on success, check output
            $successPatterns = @("successfully installed", "has been installed", "install completed")
            $foundSuccess = $false
            foreach ($pattern in $successPatterns) {
                if ($chocoOutput | Select-String -Pattern $pattern -Quiet) {
                    $foundSuccess = $true
                    break
                }
            }
            
            if ($foundSuccess) {
                $msg = "  [OK] " + $PackageName + " installed (non-standard exit code)"
                Write-ColorOutput $msg "Yellow"
                return $true
            } else {
                $msg = "  [FAIL] " + $PackageName + " installation failed with exit code " + $LASTEXITCODE
                Write-ColorOutput $msg "Red"
                return $false
            }
        }
    } catch {
        # Try to extract a more meaningful error message
        $errorMsg = $_.Exception.Message
        if ($errorMsg -like "*already installed*") {
            $msg = "  [OK] " + $PackageName + " was already installed"
            Write-ColorOutput $msg "DarkGray"
            return $true
        } else {
            $msg = "  [FAIL] Failed to install " + $PackageName + ": " + $errorMsg
            Write-ColorOutput $msg "Red"
            return $false
        }
    }
}

# Function to install multiple packages
function Install-PackageGroup {
    param(
        [string]$GroupName,
        [hashtable]$Packages
    )
    
    $msg = "`nInstalling " + $GroupName + "..."
    Write-ColorOutput $msg "Cyan"
    
    $success = 0
    $failed = 0
    $skipped = 0
    
    foreach ($package in $Packages.GetEnumerator()) {
        $packageName = $package.Key
        $checkCommands = $package.Value
        
        # First check if already installed on system
        if (Test-ProgramInstalled -ProgramName $packageName -CheckCommands $checkCommands) {
            $msg = "  [SKIP] " + $packageName + " is already installed on system"
            Write-ColorOutput $msg "DarkGray"
            $skipped++
            continue
        }
        
        # Try to install via Chocolatey
        $installed = Install-ChocoPackage -PackageName $packageName -CheckCommands $checkCommands -ForceReinstall $Force
        if (-not $installed) {
            # Retry once if failed
            Write-ColorOutput "  Retrying $packageName..." "Yellow"
            Start-Sleep -Seconds 2
            $installed = Install-ChocoPackage -PackageName $packageName -CheckCommands $checkCommands -ForceReinstall $Force
        }
        
        if ($installed) {
            $success++
        } else {
            $failed++
        }
    }
    
    $msg = $GroupName + ": " + $success + " installed, " + $failed + " failed, " + $skipped + " skipped"
    Write-ColorOutput $msg "Cyan"
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
            $msg = "  [OK] " + $DisplayName + " is installed: " + $version
            Write-ColorOutput $msg "Green"
            return $true
        } catch {
            $msg = "  [OK] " + $DisplayName + " is installed (version check failed)"
            Write-ColorOutput $msg "Yellow"
            return $true
        }
    } else {
        $msg = "  [FAIL] " + $DisplayName + " is not installed"
        Write-ColorOutput $msg "Red"
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
    
    # Define package groups with their detection commands
    $corePackages = @{
        'git' = @('git', 'git.exe')
        'vscode' = @('code', 'code.exe', 'code-insiders')
        '7zip' = @('7z', '7z.exe', '7za.exe')
        'powershell-core' = @('pwsh', 'pwsh.exe')
    }
    
    # Check if Windows Terminal needs to be installed
    $wtInstalled = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
    if (-not $wtInstalled) {
        # Check if installed via other means
        $wtPath = "$env:LocalAppData\Microsoft\WindowsApps\wt.exe"
        if (-not (Test-Path $wtPath)) {
            $corePackages['microsoft-windows-terminal'] = @('wt', 'wt.exe')
        } else {
            Write-ColorOutput "Windows Terminal is already installed" "Green"
        }
    } else {
        Write-ColorOutput "Windows Terminal is already installed (Store version)" "Green"
    }
    
    $nodePackages = @{
        'nodejs-lts' = @('node', 'node.exe', 'npm', 'npm.cmd')
        'yarn' = @('yarn', 'yarn.cmd', 'yarn.ps1')
        'pnpm' = @('pnpm', 'pnpm.cmd', 'pnpm.ps1')
    }
    
    $javaPackages = @{
        'openjdk17' = @('java', 'java.exe', 'javac', 'javac.exe')
        'maven' = @('mvn', 'mvn.cmd', 'mvn.bat')
        'gradle' = @('gradle', 'gradle.bat')
    }
    
    # .NET packages - if dotnet exists, all components are likely installed
    $dotnetPackages = @{
        'dotnet-sdk' = @('dotnet', 'dotnet.exe')
    }
    
    $dockerPackages = @{
        'docker-desktop' = @('docker', 'docker.exe', 'docker-compose', 'docker-compose.exe')
    }
    
    $databasePackages = @{
        'mongodb' = @('mongo', 'mongod', 'mongo.exe', 'mongod.exe')
        'postgresql' = @('psql', 'psql.exe', 'postgres', 'postgres.exe')
        'dbeaver' = @('dbeaver', 'dbeaver.exe')
    }
    
    $utilityPackages = @{
        'curl' = @('curl', 'curl.exe')
        'wget' = @('wget', 'wget.exe')
        'jq' = @('jq', 'jq.exe')
        'make' = @('make', 'make.exe', 'mingw32-make', 'mingw32-make.exe')
        'python' = @('python', 'python.exe', 'python3', 'py', 'py.exe')
        'gh' = @('gh', 'gh.exe')
    }
    
    $apiPackages = @{
        'postman' = @('postman', 'Postman.exe')
        'insomnia-rest-api-client' = @('insomnia', 'Insomnia.exe')
    }
    
    # Install package groups
    Install-PackageGroup -GroupName "Core Development Tools" -Packages $corePackages
    Install-PackageGroup -GroupName "Node.js Development Tools" -Packages $nodePackages
    
    # Install TypeScript via npm after Node.js is installed
    if (Test-CommandExists "npm") {
        Write-ColorOutput "`nInstalling TypeScript via npm..." "Cyan"
        & npm install -g typescript 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  [OK] TypeScript installed successfully via npm" "Green"
        } else {
            Write-ColorOutput "  [FAIL] TypeScript installation failed via npm" "Red"
        }
    }
    
    if (-not $Minimal) {
        Install-PackageGroup -GroupName "Java Development Tools" -Packages $javaPackages
        
        # Special handling for .NET - check if dotnet is already installed
        if (Test-CommandExists "dotnet") {
            Write-ColorOutput "`n.NET SDK is already installed on system" "Green"
            try {
                $dotnetVersion = & dotnet --version 2>&1 | Select-Object -First 1
                Write-ColorOutput "  Version: $dotnetVersion" "DarkGray"
                $dotnetRuntimes = & dotnet --list-runtimes 2>&1
                Write-ColorOutput "  Runtimes installed: $(($dotnetRuntimes | Measure-Object -Line).Lines)" "DarkGray"
            } catch {
                # Ignore version check errors
            }
        } else {
            Install-PackageGroup -GroupName ".NET/C# Development Tools" -Packages $dotnetPackages
        }
        
        Install-PackageGroup -GroupName "Utility Tools" -Packages $utilityPackages
        Install-PackageGroup -GroupName "API Development Tools" -Packages $apiPackages
        
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
    
    # Show summary of installations
    Write-ColorOutput "Installation Summary:" "Cyan"
    $installedPackages = & choco list --local-only --limit-output 2>&1
    $packageCount = ($installedPackages | Measure-Object -Line).Lines
    Write-ColorOutput "Total packages installed via Chocolatey: $packageCount" "Green"
    
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
    Write-ColorOutput "`nScript completed successfully!" "Green"
    exit 0
} catch {
    Write-ColorOutput "`nERROR: An unexpected error occurred:" "Red"
    Write-ColorOutput $_.Exception.Message "Red"
    if ($_.ScriptStackTrace) {
        Write-ColorOutput "`nStack Trace:" "DarkGray"
        Write-ColorOutput $_.ScriptStackTrace "DarkGray"
    }
    Write-ColorOutput "`nThe script encountered an error but may have partially completed." "Yellow"
    Write-ColorOutput "Check the installation summary above for details." "Yellow"
    exit 1
}