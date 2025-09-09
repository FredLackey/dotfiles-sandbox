#!/usr/bin/env powershell
# Windows Installation Bootstrap Script
# This script downloads and executes the main setup script

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install, run the following command in an elevated PowerShell prompt:" -ForegroundColor Cyan
    Write-Host 'Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString("https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/install.ps1"))' -ForegroundColor White
    return
}

Write-Host "Windows Development Environment Installer" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Set execution policy for this session
    Set-ExecutionPolicy Bypass -Scope Process -Force
    
    # Enable TLS 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    
    # Download and execute the main setup script
    Write-Host "Downloading setup script..." -ForegroundColor Yellow
    $setupScript = (New-Object System.Net.WebClient).DownloadString('https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/setup.ps1')
    
    Write-Host "Executing setup script..." -ForegroundColor Yellow
    Write-Host ""
    
    # Execute the setup script
    Invoke-Expression $setupScript
    
} catch {
    Write-Host "ERROR: Failed to download or execute setup script" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
}