#!/bin/bash

# Output formatting utilities for clean console display
# Provides functions for pretty printing with spinners, checkmarks, and error marks

# Color codes
readonly COLOR_RED=1
readonly COLOR_GREEN=2
readonly COLOR_YELLOW=3
readonly COLOR_PURPLE=5

# Display colored output
print_in_color() {
    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"
}

print_in_green() {
    print_in_color "$1" $COLOR_GREEN
}

print_in_purple() {
    print_in_color "$1" $COLOR_PURPLE
}

print_in_red() {
    print_in_color "$1" $COLOR_RED
}

print_in_yellow() {
    print_in_color "$1" $COLOR_YELLOW
}

# Print formatted messages
print_error() {
    print_in_red "   [✖] $1 $2\n"
}

print_success() {
    print_in_green "   [✔] $1\n"
}

print_warning() {
    print_in_yellow "   [!] $1\n"
}

print_info() {
    print_in_purple "   [i] $1\n"
}

print_question() {
    print_in_yellow "   [?] $1"
}

print_title() {
    print_in_purple "\n   $1\n\n"
}

# Print result based on exit code
print_result() {
    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi
    return "$1"
}

# Print error output from a stream
print_error_stream() {
    while read -r line; do
        print_error "↳ ERROR: $line"
    done
}

# Show spinner while a process is running
show_spinner() {
    local -r FRAMES='/-\|'
    local -r NUMBER_OR_FRAMES=${#FRAMES}
    local -r PID="$1"
    local -r MSG="$2"
    
    local i=0
    local frameText=""
    
    # Provide space for spinner
    printf "\n"
    tput cuu 1
    tput sc
    
    # Display spinner while process is running
    while kill -0 "$PID" &>/dev/null; do
        frameText="   [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"
        printf "%s" "$frameText"
        sleep 0.2
        tput rc
    done
}

# Execute command with spinner and clean output
execute() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
    
    local exitCode=0
    local cmdsPID=""
    
    # Execute commands in background, completely suppressing all output
    (eval "$CMDS") > "$TMP_FILE" 2>&1 &
    
    cmdsPID=$!
    
    # Show spinner while commands execute
    show_spinner "$cmdsPID" "$MSG"
    
    # Wait for commands to complete
    wait "$cmdsPID" &> /dev/null
    exitCode=$?
    
    # Print result
    print_result $exitCode "$MSG"
    
    # Show errors if command failed
    if [ $exitCode -ne 0 ]; then
        print_error_stream < "$TMP_FILE"
    fi
    
    rm -rf "$TMP_FILE"
    
    return $exitCode
}

# Execute command quietly (no spinner for quick operations)
execute_quiet() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
    
    local exitCode=0
    
    # Execute command and capture output
    eval "$CMDS" &> "$TMP_FILE"
    exitCode=$?
    
    # Print result
    print_result $exitCode "$MSG"
    
    # Show errors if command failed
    if [ $exitCode -ne 0 ]; then
        print_error_stream < "$TMP_FILE"
    fi
    
    rm -rf "$TMP_FILE"
    
    return $exitCode
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Create directory with pretty output
make_directory() {
    if [ -n "$1" ]; then
        if [ -e "$1" ]; then
            if [ ! -d "$1" ]; then
                print_error "$1 - a file with the same name already exists!"
                return 1
            else
                print_success "$1"
                return 0
            fi
        else
            execute "mkdir -p $1" "$1"
        fi
    fi
}