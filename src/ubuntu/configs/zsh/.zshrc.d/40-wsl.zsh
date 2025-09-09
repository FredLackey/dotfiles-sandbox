# WSL-specific configurations and aliases
# This file is only loaded when running in WSL environment

# Check if we're in WSL
if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
    
    # Windows interop aliases
    alias explorer='explorer.exe'
    alias code='code.exe'
    alias notepad='notepad.exe'
    
    # Navigate to Windows home directory
    alias winhome='cd /mnt/c/Users/$USER'
    alias windesktop='cd /mnt/c/Users/$USER/Desktop'
    alias windocs='cd /mnt/c/Users/$USER/Documents'
    alias windownloads='cd /mnt/c/Users/$USER/Downloads'
    
    # Copy/paste integration with Windows clipboard
    alias pbcopy='clip.exe'
    alias pbpaste='powershell.exe -command "Get-Clipboard"'
    
    # Open current directory in Windows Explorer
    wslopen() {
        if [ $# -eq 0 ]; then
            explorer.exe .
        else
            explorer.exe "$@"
        fi
    }
    
    # Convert WSL path to Windows path
    winpath() {
        wslpath -w "${1:-.}"
    }
    
    # Convert Windows path to WSL path
    wslpath() {
        command wslpath -u "$1"
    }
    
fi