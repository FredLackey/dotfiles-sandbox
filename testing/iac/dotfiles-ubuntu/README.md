# Ubuntu EC2 Instance Terraform Package

This Terraform package deploys a single Ubuntu EC2 instance in AWS Commerical with SSH access.

## Prerequisites

1. AWS CLI configured with the `bh-fred-sandbox` profile
2. Terraform installed (>= 1.0)
3. Valid AWS SSO session

## Setup

1. **Initialize the backend** (if not already done):
   ```bash
   cd scripts
   ./setup-state-bucket.sh bh-fred-sandbox
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Deploy the infrastructure**:
   ```bash
   terraform apply
   ```

## What Gets Created

- **EC2 Instance**: Ubuntu 24.04 LTS (t3.micro) in `us-east-1a`
- **Security Group**: Allows SSH (22), HTTP (80), and HTTPS (443) from `24.181.4.123/32`
- **SSH Key Pair**: Generated automatically and saved as `dotfiles-ubuntu-key.pem`
- **Elastic IP**: Static public IP address for the instance

## Accessing the Instance

After deployment, use the SSH command from the output:

```bash
# Get the SSH command from Terraform output
terraform output ssh_connection_command

# Or manually connect using:
ssh -i dotfiles-ubuntu-key.pem ubuntu@<public-ip>
```

## Configuration

All configuration is hardcoded in `terraform.tfvars`:

- **VPC ID**: `vpc-0525f4b966f4e9a78` (default VPC)
- **Subnet ID**: `subnet-0b5e838ce3bba1a7a` (us-east-1a)
- **AMI ID**: `ami-0360c520857e3138f` (Ubuntu 24.04 LTS)
- **Allowed IP**: `24.181.4.123/32`

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: The private key file (`dotfiles-ubuntu-key.pem`) will be deleted during destruction.

## Files

- `provider.tf` - Provider configuration
- `backend.tf` - S3 backend configuration
- `variables.tf` - Variable definitions
- `terraform.tfvars` - Hardcoded values
- `main.tf` - Main infrastructure resources
- `outputs.tf` - Output values
