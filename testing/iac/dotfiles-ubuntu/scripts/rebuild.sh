#!/bin/bash

# Rebuild the Terraform infrastructure
# Destroys and recreates the EC2 instance for testing

# Exit on any error
set -e

# Configuration
IAC_PROJECT="dotfiles-ubuntu"

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

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
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
    print_info "Starting infrastructure rebuild..."
    
    # Find repository root
    repo_root=$(find_repo_root)
    if [ $? -ne 0 ]; then
        print_error "Failed to find repository root"
        exit 1
    fi
    
    # Change to Terraform directory
    terraform_dir="$repo_root/testing/iac/${IAC_PROJECT}"
    if [ ! -d "$terraform_dir" ]; then
        print_error "Terraform project directory not found: $terraform_dir"
        exit 1
    fi
    
    cd "$terraform_dir"
    print_info "Working in: $terraform_dir"
    
    # Check if Terraform is initialized
    if [ ! -d ".terraform" ]; then
        print_info "Initializing Terraform..."
        terraform init || {
            print_error "Terraform initialization failed"
            exit 1
        }
    fi
    
    # Check if any resources exist to destroy
    print_info "Checking current infrastructure state..."
    if terraform state list 2>/dev/null | grep -q .; then
        print_warning "Destroying existing infrastructure..."
        terraform destroy -auto-approve || {
            print_error "Terraform destroy failed"
            exit 1
        }
        print_success "Infrastructure destroyed"
    else
        print_info "No existing infrastructure to destroy"
    fi
    
    # Apply new infrastructure
    print_info "Creating new infrastructure..."
    terraform apply -auto-approve || {
        print_error "Terraform apply failed"
        exit 1
    }
    
    # Get the new instance IP
    print_info "Retrieving instance information..."
    instance_ip=$(terraform output -raw instance_public_ip 2>&1)
    if [ $? -eq 0 ] && [ -n "$instance_ip" ] && [ "$instance_ip" != "null" ]; then
        print_success "Infrastructure rebuilt successfully!"
        print_info "Instance IP: $instance_ip"
        print_info "SSH Key: $terraform_dir/${IAC_PROJECT}-key.pem"
        echo ""
        print_info "To connect, run: ./scripts/connect.sh (from $terraform_dir)"
        print_info "Or run: testing/iac/${IAC_PROJECT}/scripts/connect.sh (from repo root)"
    else
        print_warning "Infrastructure created but could not retrieve IP address"
    fi
    
    return 0
}

# Execute main function
main "$@"