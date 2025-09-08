#!/bin/bash

# Utility functions for dotfiles setup scripts
# These functions will be copied into platform scripts to maintain self-contained execution
# Each platform script should copy the functions it needs rather than sourcing this file

# Print colored output for different message types
print_error() {
    # Print error message in red to stderr
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

print_success() {
    # Print success message in green
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_info() {
    # Print informational message in blue
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_warning() {
    # Print warning message in yellow
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# Check if a command exists in the system
check_command() {
    local command_name="$1"
    
    if command -v "$command_name" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Create directory if it doesn't exist (idempotent)
ensure_directory() {
    local dir_path="$1"
    
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        print_info "Created directory: $dir_path"
    fi
}

# Check if a line exists in a file (for idempotent file modifications)
line_exists_in_file() {
    local search_string="$1"
    local file_path="$2"
    
    if [ ! -f "$file_path" ]; then
        return 1
    fi
    
    if grep -Fxq "$search_string" "$file_path"; then
        return 0
    else
        return 1
    fi
}

# Add line to file if it doesn't exist (idempotent)
add_line_to_file() {
    local line_to_add="$1"
    local file_path="$2"
    
    if ! line_exists_in_file "$line_to_add" "$file_path"; then
        echo "$line_to_add" >> "$file_path"
        print_info "Added to $file_path: $line_to_add"
    fi
}

# Check if pattern exists in file (for more flexible searches)
pattern_exists_in_file() {
    local pattern="$1"
    local file_path="$2"
    
    if [ ! -f "$file_path" ]; then
        return 1
    fi
    
    if grep -q "$pattern" "$file_path"; then
        return 0
    else
        return 1
    fi
}

# Download file using curl or wget (cross-platform)
download_file() {
    local url="$1"
    local output_path="$2"
    
    if check_command curl; then
        curl -LsS "$url" -o "$output_path"
    elif check_command wget; then
        wget -qO "$output_path" "$url"
    else
        print_error "Neither curl nor wget is available"
        return 1
    fi
}

# Verify script is running with bash
verify_bash() {
    if [ -z "$BASH_VERSION" ]; then
        print_error "This script must be run with bash"
        exit 1
    fi
}

# Get absolute path of a file or directory
get_absolute_path() {
    local path="$1"
    
    if [ -d "$path" ]; then
        echo "$(cd "$path" && pwd)"
    elif [ -f "$path" ]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        echo "$path"
    fi
}

# Check if running with sufficient privileges for system changes
check_privileges() {
    local require_sudo="$1"
    
    if [ "$require_sudo" = "true" ]; then
        if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then
            print_warning "This operation may require administrator privileges"
            print_info "You may be prompted for your password"
        fi
    fi
}

# Create backup of a file before modifying it
backup_file() {
    local file_path="$1"
    local backup_suffix="${2:-backup}"
    
    if [ -f "$file_path" ]; then
        local backup_path="${file_path}.${backup_suffix}.$(date +%Y%m%d_%H%M%S)"
        cp "$file_path" "$backup_path"
        print_info "Created backup: $backup_path"
    fi
}

# Verify checksum of downloaded file (optional security check)
verify_checksum() {
    local file_path="$1"
    local expected_checksum="$2"
    local checksum_type="${3:-sha256}"
    
    if [ ! -f "$file_path" ]; then
        print_error "File not found: $file_path"
        return 1
    fi
    
    local actual_checksum=""
    
    case "$checksum_type" in
        sha256)
            if check_command sha256sum; then
                actual_checksum=$(sha256sum "$file_path" | cut -d' ' -f1)
            elif check_command shasum; then
                actual_checksum=$(shasum -a 256 "$file_path" | cut -d' ' -f1)
            fi
            ;;
        md5)
            if check_command md5sum; then
                actual_checksum=$(md5sum "$file_path" | cut -d' ' -f1)
            elif check_command md5; then
                actual_checksum=$(md5 -q "$file_path")
            fi
            ;;
    esac
    
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        return 0
    else
        print_error "Checksum verification failed"
        return 1
    fi
}

# Clean up temporary files and directories
cleanup_temp() {
    local temp_path="$1"
    
    if [ -n "$temp_path" ] && [ -e "$temp_path" ]; then
        rm -rf "$temp_path"
        print_info "Cleaned up temporary files"
    fi
}

# Set trap for cleanup on script exit
set_cleanup_trap() {
    local cleanup_function="$1"
    
    trap "$cleanup_function" EXIT INT TERM
}

# Example main function (this file is not meant to be executed directly)
main() {
    print_error "This utility file should not be executed directly"
    print_info "Copy needed functions into your platform-specific setup scripts"
    exit 1
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi