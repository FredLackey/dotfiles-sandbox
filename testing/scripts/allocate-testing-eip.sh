#! /bin/bash

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
DISCOVERY_FILE=""
AWS_PROFILE=""
REGION=""

usage() {
    cat << EOF
Usage: $0 -f <discovery_file> -p <aws_profile>

Allocates or finds an available Elastic IP address for testing.

Options:
    -f FILE     Path to the discovery JSON file (e.g., ./testing/scripts/flackey-east.json)
    -p PROFILE  AWS SSO profile to use (e.g., cvle-flackey)
    -h          Show this help message

Example:
    $0 -f ./testing/scripts/flackey-east.json -p cvle-flackey

Output:
    Returns JSON with EIP details including allocation ID, public IP, and region.
EOF
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

parse_arguments() {
    while getopts "f:p:h" opt; do
        case $opt in
            f)
                DISCOVERY_FILE="$OPTARG"
                ;;
            p)
                AWS_PROFILE="$OPTARG"
                ;;
            h)
                usage
                exit 0
                ;;
            \?)
                log_error "Invalid option: -$OPTARG"
                usage
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$DISCOVERY_FILE" ]]; then
        log_error "Discovery file (-f) is required"
        usage
        exit 1
    fi

    if [[ -z "$AWS_PROFILE" ]]; then
        log_error "AWS profile (-p) is required"
        usage
        exit 1
    fi
}

validate_inputs() {
    # Check if discovery file exists
    if [[ ! -f "$DISCOVERY_FILE" ]]; then
        log_error "Discovery file not found: $DISCOVERY_FILE"
        exit 1
    fi

    # Validate JSON structure and extract region
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed"
        exit 1
    fi

    # Extract region from discovery file
    REGION=$(jq -r '.discovery_metadata.region // empty' "$DISCOVERY_FILE" 2>/dev/null)
    if [[ -z "$REGION" ]]; then
        log_error "Could not extract region from discovery file"
        exit 1
    fi

    log_info "Using region: $REGION"
    log_info "Using AWS profile: $AWS_PROFILE"
}

find_existing_eip() {
    log_info "Checking for existing unused Elastic IPs..."
    
    # Get existing EIPs from discovery file
    local existing_eips
    existing_eips=$(jq -r '.elastic_ips.Addresses[]? | select(.InstanceId == null and .NetworkInterfaceId == null) | {AllocationId, PublicIp}' "$DISCOVERY_FILE" 2>/dev/null)
    
    if [[ -n "$existing_eips" ]]; then
        log_success "Found existing unused EIP"
        echo "$existing_eips" | jq -c ". + {\"Region\": \"$REGION\", \"Status\": \"existing\"}"
        return 0
    fi
    
    return 1
}

get_public_subnet() {
    # Get a public subnet ID from the discovery file
    jq -r '.vpcs[0].subnets.Subnets[]? | select(.MapPublicIpOnLaunch == true) | .SubnetId' "$DISCOVERY_FILE" | head -1
}

create_new_eip() {
    log_info "No unused EIP found. Creating a new Elastic IP..."
    
    # Get a public subnet for domain specification
    local subnet_id
    subnet_id=$(get_public_subnet)
    
    if [[ -z "$subnet_id" ]]; then
        log_error "No public subnets found in discovery file"
        exit 1
    fi
    
    # Create new EIP
    local eip_result
    if eip_result=$(aws ec2 allocate-address \
        --region "$REGION" \
        --profile "$AWS_PROFILE" \
        --domain vpc \
        --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=testing-eip},{Key=CreatedBy,Value=allocate-testing-eip.sh},{Key=Purpose,Value=testing}]" \
        --output json 2>/dev/null); then
        
        local allocation_id public_ip
        allocation_id=$(echo "$eip_result" | jq -r '.AllocationId')
        public_ip=$(echo "$eip_result" | jq -r '.PublicIp')
        
        log_success "Created new EIP: $public_ip (Allocation ID: $allocation_id)"
        
        # Return the EIP details
        jq -n \
            --arg allocation_id "$allocation_id" \
            --arg public_ip "$public_ip" \
            --arg region "$REGION" \
            '{
                "AllocationId": $allocation_id,
                "PublicIp": $public_ip,
                "Region": $region,
                "Status": "created"
            }'
        return 0
    else
        log_error "Failed to create new Elastic IP"
        exit 1
    fi
}

main() {
    parse_arguments "$@"
    validate_inputs
    
    # Try to find existing unused EIP first
    if find_existing_eip; then
        exit 0
    fi
    
    # If no existing EIP found, create a new one
    create_new_eip
}

main "$@"