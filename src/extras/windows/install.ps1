#!/usr/bin/env powershell
# Windows Installation Bootstrap Script
# Downloads and executes the setup script

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "ERROR: Administrator privileges required" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Right-click on PowerShell" -ForegroundColor White
    Write-Host "2. Select 'Run as Administrator'" -ForegroundColor White
    Write-Host "3. Run this command again" -ForegroundColor White
    Write-Host ""
    return
}

Write-Host ""
Write-Host "Windows Development Environment Installer" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Set TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download the setup script (using simplified version)
Write-Host "Downloading setup script..." -ForegroundColor Yellow
$url = "https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/extras/windows/setup-simple.ps1"

try {
    $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $tempFile)
    
    Write-Host "Starting installation..." -ForegroundColor Yellow
    Write-Host ""
    
    # Execute the downloaded script
    & $tempFile
    
    # Clean up
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to download or execute setup script" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}