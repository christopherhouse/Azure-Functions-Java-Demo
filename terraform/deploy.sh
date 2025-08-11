#!/bin/bash

# Terraform deployment script for Azure Functions Java Demo
# Usage: ./deploy.sh <environment> [plan|apply|destroy]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR"
ENVIRONMENTS_DIR="$TERRAFORM_DIR/environments"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <environment> [action]"
    echo ""
    echo "Arguments:"
    echo "  environment    Environment to deploy (dev, prod)"
    echo "  action         Action to perform (plan, apply, destroy) [default: plan]"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan      # Plan deployment for dev environment"
    echo "  $0 dev apply     # Apply deployment for dev environment"
    echo "  $0 prod destroy  # Destroy prod environment"
    echo ""
    echo "Prerequisites:"
    echo "  - Azure CLI logged in (az login)"
    echo "  - Terraform installed"
    echo "  - Appropriate Azure permissions"
    echo "  - Backend storage account created"
}

# Function to validate environment
validate_environment() {
    local env=$1
    
    if [[ ! "$env" =~ ^(dev|prod)$ ]]; then
        log_error "Invalid environment: $env"
        log_error "Supported environments: dev, prod"
        exit 1
    fi
    
    if [[ ! -d "$ENVIRONMENTS_DIR/$env" ]]; then
        log_error "Environment directory not found: $ENVIRONMENTS_DIR/$env"
        exit 1
    fi
    
    if [[ ! -f "$ENVIRONMENTS_DIR/$env/terraform.tfvars" ]]; then
        log_error "Terraform variables file not found: $ENVIRONMENTS_DIR/$env/terraform.tfvars"
        exit 1
    fi
    
    if [[ ! -f "$ENVIRONMENTS_DIR/$env/backend.conf" ]]; then
        log_error "Backend configuration file not found: $ENVIRONMENTS_DIR/$env/backend.conf"
        exit 1
    fi
}

# Function to validate action
validate_action() {
    local action=$1
    
    if [[ ! "$action" =~ ^(plan|apply|destroy)$ ]]; then
        log_error "Invalid action: $action"
        log_error "Supported actions: plan, apply, destroy"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed and logged in
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Function to initialize Terraform
init_terraform() {
    local env=$1
    
    log_info "Initializing Terraform for environment: $env"
    
    cd "$TERRAFORM_DIR"
    
    terraform init \
        -backend-config="$ENVIRONMENTS_DIR/$env/backend.conf" \
        -reconfigure
    
    if [[ $? -eq 0 ]]; then
        log_success "Terraform initialization completed"
    else
        log_error "Terraform initialization failed"
        exit 1
    fi
}

# Function to plan Terraform deployment
plan_terraform() {
    local env=$1
    
    log_info "Planning Terraform deployment for environment: $env"
    
    cd "$TERRAFORM_DIR"
    
    terraform plan \
        -var-file="$ENVIRONMENTS_DIR/$env/terraform.tfvars" \
        -out="$ENVIRONMENTS_DIR/$env/terraform.plan"
    
    if [[ $? -eq 0 ]]; then
        log_success "Terraform plan completed successfully"
        log_info "Plan saved to: $ENVIRONMENTS_DIR/$env/terraform.plan"
    else
        log_error "Terraform plan failed"
        exit 1
    fi
}

# Function to apply Terraform deployment
apply_terraform() {
    local env=$1
    
    # Skip confirmation in CI/automation environments
    if [[ "${CI:-false}" == "true" || "${TF_IN_AUTOMATION:-false}" == "true" ]]; then
        log_info "Running in automation mode, skipping confirmation"
    else
        log_warning "This will apply changes to the $env environment"
        read -p "Are you sure you want to continue? (yes/no): " confirmation
        
        if [[ "$confirmation" != "yes" ]]; then
            log_info "Deployment cancelled by user"
            exit 0
        fi
    fi
    
    log_info "Applying Terraform deployment for environment: $env"
    
    cd "$TERRAFORM_DIR"
    
    # Check if plan file exists
    if [[ -f "$ENVIRONMENTS_DIR/$env/terraform.plan" ]]; then
        terraform apply "$ENVIRONMENTS_DIR/$env/terraform.plan"
    else
        log_warning "No plan file found, running apply with var-file"
        terraform apply \
            -var-file="$ENVIRONMENTS_DIR/$env/terraform.tfvars" \
            -auto-approve
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "Terraform apply completed successfully"
        
        # Show outputs
        log_info "Deployment outputs:"
        terraform output
    else
        log_error "Terraform apply failed"
        exit 1
    fi
}

# Function to destroy Terraform deployment
destroy_terraform() {
    local env=$1
    
    log_warning "This will DESTROY all resources in the $env environment"
    log_warning "This action cannot be undone!"
    read -p "Are you absolutely sure you want to continue? (yes/no): " confirmation
    
    if [[ "$confirmation" != "yes" ]]; then
        log_info "Destroy cancelled by user"
        exit 0
    fi
    
    log_info "Destroying Terraform deployment for environment: $env"
    
    cd "$TERRAFORM_DIR"
    
    terraform destroy \
        -var-file="$ENVIRONMENTS_DIR/$env/terraform.tfvars" \
        -auto-approve
    
    if [[ $? -eq 0 ]]; then
        log_success "Terraform destroy completed successfully"
    else
        log_error "Terraform destroy failed"
        exit 1
    fi
}

# Main function
main() {
    # Parse arguments
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi
    
    local environment=$1
    local action=${2:-plan}
    
    # Validate arguments
    validate_environment "$environment"
    validate_action "$action"
    
    # Check prerequisites
    check_prerequisites
    
    # Initialize Terraform
    init_terraform "$environment"
    
    # Execute the requested action
    case "$action" in
        plan)
            plan_terraform "$environment"
            ;;
        apply)
            apply_terraform "$environment"
            ;;
        destroy)
            destroy_terraform "$environment"
            ;;
    esac
    
    log_success "Operation completed successfully"
}

# Execute main function with all arguments
main "$@"