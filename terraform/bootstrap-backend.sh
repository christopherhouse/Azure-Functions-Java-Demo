#!/bin/bash

# Bootstrap script for Terraform backend storage
# This script ensures the required Azure Storage account and container exist
# before Terraform initialization attempts to use them.

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENTS_DIR="$SCRIPT_DIR/environments"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[BOOTSTRAP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[BOOTSTRAP]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[BOOTSTRAP]${NC} $1"
}

log_error() {
    echo -e "${RED}[BOOTSTRAP]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <environment>"
    echo ""
    echo "Arguments:"
    echo "  environment    Environment to bootstrap (dev, prod, local)"
    echo ""
    echo "Examples:"
    echo "  $0 dev     # Bootstrap backend storage for dev environment"
    echo "  $0 prod    # Bootstrap backend storage for prod environment"
    echo ""
    echo "This script will:"
    echo "  1. Read the backend configuration for the specified environment"
    echo "  2. Check if the storage account and container exist"
    echo "  3. Fail if they do not exist"
    echo "  4. Ensure proper permissions are set"
}

# Function to parse backend configuration
parse_backend_config() {
    local env=$1
    local backend_file="$ENVIRONMENTS_DIR/$env/backend.conf"
    
    if [[ ! -f "$backend_file" ]]; then
        log_error "Backend configuration file not found: $backend_file"
        exit 1
    fi
    
    # Parse the backend configuration file
    eval $(grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=' "$backend_file" | sed 's/[[:space:]]*//g' | sed 's/^/BACKEND_/')
    
    # Validate required variables
    if [[ -z "$BACKEND_resource_group_name" ]]; then
        log_error "resource_group_name not found in backend configuration"
        exit 1
    fi
    
    if [[ -z "$BACKEND_storage_account_name" ]]; then
        log_error "storage_account_name not found in backend configuration"
        exit 1
    fi
    
    if [[ -z "$BACKEND_container_name" ]]; then
        log_error "container_name not found in backend configuration"
        exit 1
    fi
    
    # Remove quotes if present
    BACKEND_resource_group_name=$(echo "$BACKEND_resource_group_name" | tr -d '"')
    BACKEND_storage_account_name=$(echo "$BACKEND_storage_account_name" | tr -d '"')
    BACKEND_container_name=$(echo "$BACKEND_container_name" | tr -d '"')
    
    log_info "Parsed backend configuration:"
    log_info "  Resource Group: $BACKEND_resource_group_name"
    log_info "  Storage Account: $BACKEND_storage_account_name"
    log_info "  Container: $BACKEND_container_name"
}

# Function to check if Azure CLI is logged in
check_azure_login() {
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    local account_name=$(az account show --query name -o tsv)
    local subscription_id=$(az account show --query id -o tsv)
    log_info "Using Azure subscription: $account_name ($subscription_id)"
}

# Function to create container if it doesn't exist
ensure_container() {
    local storage_name=$1
    local container_name=$2
    
    log_info "Checking if container '$container_name' exists..."
    
    if az storage container show --name "$container_name" --account-name "$storage_name" &> /dev/null; then
        log_success "Container '$container_name' exists"
    else
        log_error "Container '$container_name' does not exist. Please provision it before running this script."
        exit 1
    fi
}

# Function to validate the setup
validate_setup() {
    local storage_name=$1
    local container_name=$2
    
    log_info "Validating backend storage setup..."
    
    if az storage blob list --container-name "$container_name" --account-name "$storage_name" &> /dev/null; then
        log_success "Backend storage is properly configured and accessible"
    else
        log_error "Failed to access the container. Please check permissions."
        exit 1
    fi
}

# Main function
main() {
    local environment=$1
    
    # Validate arguments
    if [[ -z "$environment" ]]; then
        log_error "Environment is required"
        show_usage
        exit 1
    fi
    
    if [[ ! "$environment" =~ ^(dev|prod|local)$ ]]; then
        log_error "Environment must be one of: dev, prod, local"
        exit 1
    fi
    
    log_info "Bootstrapping Terraform backend storage for environment: $environment"
    
    # Check prerequisites
    check_azure_login
    
    # Parse backend configuration
    parse_backend_config "$environment"
    
    # Ensure container exists
    ensure_container "$BACKEND_storage_account_name" "$BACKEND_container_name"
    # Validate the setup
    validate_setup "$BACKEND_storage_account_name" "$BACKEND_container_name"
    
    log_success "Backend storage bootstrap completed successfully!"
    log_info "Terraform can now be initialized with: terraform init -backend-config=\"environments/$environment/backend.conf\""
}

# Run main function with all arguments
main "$@"