#!/bin/bash

# Setup script for S3 state bucket and DynamoDB table
# This script creates the AWS resources needed for Terraform remote state
# For Briskhaven.com SES infrastructure

# Copyright 2025, Fred Lackey (https://fredlackey.com)

# Usage: ./setup-state-bucket.sh [AWS_PROFILE]

set -e

# Configuration for Briskhaven.com SES infrastructure
BUCKET_NAME="tfstate-ses-dotfiles-sandbox"
REGION="us-east-1"
DYNAMODB_TABLE="tfstate-ses-dotfiles-sandbox-locks"

# AWS Profile handling
AWS_PROFILE="${1:-bh-fred-sandbox}"
echo "Using AWS profile: $AWS_PROFILE"

# Set AWS profile for all AWS CLI commands
export AWS_PROFILE="$AWS_PROFILE"

# Function to check if SSO session is valid
check_sso_session() {
    echo "Checking AWS SSO session..."
    
    # Try to get caller identity to test if credentials are valid
    if aws sts get-caller-identity --output text --query 'Account' --no-cli-pager >/dev/null 2>&1; then
        echo "✅ AWS credentials are valid"
        return 0
    else
        echo "❌ AWS credentials are not valid or expired"
        return 1
    fi
}

# Function to initiate SSO login
sso_login() {                       
    echo "Initiating AWS SSO login for profile: $AWS_PROFILE"
    aws sso login --profile "$AWS_PROFILE" --no-cli-pager
    
    # Verify login was successful
    if check_sso_session; then
        echo "✅ SSO login successful"
    else
        echo "❌ SSO login failed or credentials still invalid"
        exit 1
    fi
}

# Check SSO session and login if needed
if ! check_sso_session; then
    echo "SSO session is not active or expired. Initiating login..."
    sso_login
fi

echo "Setting up AWS resources for Terraform state backend..."

# Check if bucket exists
if aws s3 ls "s3://$BUCKET_NAME" --no-cli-pager 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket: $BUCKET_NAME"
    
    # Create bucket
    aws s3 mb "s3://$BUCKET_NAME" --region "$REGION" --no-cli-pager
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled \
        --no-cli-pager
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }' \
        --no-cli-pager
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
        --no-cli-pager
    
    echo "✅ S3 bucket created and configured: $BUCKET_NAME"
else
    echo "✅ S3 bucket already exists: $BUCKET_NAME"
fi

# Setup DynamoDB table for state locking
if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" --no-cli-pager >/dev/null 2>&1; then
    echo "Creating DynamoDB table for state locking: $DYNAMODB_TABLE"
    
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$REGION" \
        --no-cli-pager
    
    echo "Waiting for DynamoDB table to be active..."
    aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION" --no-cli-pager
    
    echo "✅ DynamoDB table created: $DYNAMODB_TABLE"
else
    echo "✅ DynamoDB table already exists: $DYNAMODB_TABLE"
fi

echo "✅ AWS backend resources created successfully!"
echo "✅ State locking enabled with DynamoDB"
echo "💰 DynamoDB cost: ~\$0.01/month for typical usage"
echo ""
echo "Configuration summary:"
echo "  AWS Profile: $AWS_PROFILE"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $DYNAMODB_TABLE"
echo "  Region: $REGION"
echo ""
echo "Next steps:"
echo "  export AWS_PROFILE=$AWS_PROFILE"
echo "  terraform init"
echo "  terraform plan    # Review changes"
echo "  terraform apply   # Deploy infrastructure"