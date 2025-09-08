#!/bin/bash

# Connect to the dotfiles-ubuntu EC2 instance via SSH
# Gets connection info from Terraform outputs

# Exit on error and show commands for debugging
set -e
# Uncomment for debugging
# set -x

# Configuration
IAC_PROJECT="dotfiles-ubuntu"
KEY_NAME="dotfiles-ubuntu-key"
SSH_USER="ubuntu"

# Print colored messages
print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

# Find the repository root directory
find_repo_root() {
    local current_dir="$(pwd)"
    
    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.git" ] && [ -d "$current_dir/testing" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    print_error "Could not find repository root"
    return 1
}

# Main function
main() {
    # Find repository root
    repo_root=$(find_repo_root)
    if [ $? -ne 0 ]; then
        print_error "Failed to find repository root"
        exit 1
    fi
    
    # Change to Terraform directory for the IAC project
    terraform_dir="$repo_root/testing/iac/${IAC_PROJECT}"
    if [ ! -d "$terraform_dir" ]; then
        print_error "Terraform project directory not found: $terraform_dir"
        exit 1
    fi
    
    cd "$terraform_dir"
    
    # Check if Terraform is initialized
    if [ ! -d ".terraform" ]; then
        print_error "Terraform not initialized. Run: cd testing/iac/${IAC_PROJECT} && terraform init"
        exit 1
    fi
    
    # Get the public IP from Terraform output
    print_info "Getting instance IP from Terraform..."
    instance_ip=$(terraform output -raw instance_public_ip 2>&1)
    terraform_exit_code=$?
    
    if [ $terraform_exit_code -ne 0 ]; then
        print_error "Terraform output command failed:"
        echo "$instance_ip"
        exit 1
    fi
    
    if [ -z "$instance_ip" ] || [ "$instance_ip" = "null" ]; then
        print_error "No instance IP found in Terraform outputs"
        print_info "Make sure the instance is created: cd testing/iac/${IAC_PROJECT} && terraform apply"
        exit 1
    fi
    
    # Find the SSH key file
    key_file="$repo_root/testing/iac/${IAC_PROJECT}/${KEY_NAME}.pem"
    if [ ! -f "$key_file" ]; then
        print_error "SSH key not found: $key_file"
        print_info "The key should have been created by Terraform"
        exit 1
    fi
    
    # Set proper permissions on key file
    chmod 600 "$key_file"
    
    print_info "Connecting to $instance_ip..."
    
    # Connect via SSH
    exec ssh -o StrictHostKeyChecking=no \
             -o UserKnownHostsFile=/dev/null \
             -i "$key_file" \
             "$SSH_USER@$instance_ip"
}

# Execute main function
main "$@"