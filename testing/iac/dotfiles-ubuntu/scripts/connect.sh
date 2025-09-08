#!/bin/bash

# Connect to the dotfiles-ubuntu EC2 instance via SSH
# This script is specific to the dotfiles-ubuntu Terraform project

# Exit on error
set -e

# Configuration
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

# Main function
main() {
    # Get the script's directory (should be in testing/iac/dotfiles-ubuntu/scripts)
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Move up one level to the Terraform project directory
    terraform_dir="$(dirname "$script_dir")"
    
    # Verify we're in the right place
    if [ ! -f "$terraform_dir/main.tf" ]; then
        print_error "This script must be run from testing/iac/dotfiles-ubuntu/scripts/"
        print_error "Current location: $script_dir"
        exit 1
    fi
    
    cd "$terraform_dir"
    
    # Check if Terraform is initialized
    if [ ! -d ".terraform" ]; then
        print_error "Terraform not initialized. Run: terraform init"
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
        print_info "Make sure the instance is created: terraform apply"
        exit 1
    fi
    
    # Find the SSH key file
    key_file="$terraform_dir/${KEY_NAME}.pem"
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