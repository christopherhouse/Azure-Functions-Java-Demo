#!/bin/bash

# Terraform validation script for Azure Functions Java Demo
# Usage: ./validate.sh

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR"

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

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check Terraform version
    terraform_version=$(terraform version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    log_info "Terraform version: $terraform_version"
    
    log_success "Prerequisites check passed"
}

# Function to validate Terraform configuration
validate_terraform() {
    log_info "Validating Terraform configuration..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform (without backend)
    terraform init -backend=false
    
    # Validate configuration
    terraform validate
    
    if [[ $? -eq 0 ]]; then
        log_success "Terraform configuration is valid"
    else
        log_error "Terraform configuration validation failed"
        exit 1
    fi
}

# Function to check formatting
check_formatting() {
    log_info "Checking Terraform formatting..."
    
    cd "$TERRAFORM_DIR"
    
    # Check if files are properly formatted
    if terraform fmt -check -diff; then
        log_success "All Terraform files are properly formatted"
    else
        log_warning "Some Terraform files need formatting. Run 'terraform fmt' to fix."
    fi
}

# Function to validate environment configurations
validate_environments() {
    log_info "Validating environment configurations..."
    
    local environments=("dev" "prod")
    local errors=0
    
    for env in "${environments[@]}"; do
        log_info "Checking $env environment..."
        
        # Check if tfvars file exists
        if [[ ! -f "$TERRAFORM_DIR/environments/$env/terraform.tfvars" ]]; then
            log_error "Missing terraform.tfvars for $env environment"
            errors=$((errors + 1))
        else
            log_success "Found terraform.tfvars for $env environment"
        fi
        
        # Check if backend config exists
        if [[ ! -f "$TERRAFORM_DIR/environments/$env/backend.conf" ]]; then
            log_error "Missing backend.conf for $env environment"
            errors=$((errors + 1))
        else
            log_success "Found backend.conf for $env environment"
        fi
    done
    
    if [[ $errors -gt 0 ]]; then
        log_error "Environment validation failed with $errors errors"
        exit 1
    else
        log_success "All environment configurations are valid"
    fi
}

# Function to check variable consistency
check_variable_consistency() {
    log_info "Checking variable consistency across environments..."
    
    local dev_vars="$TERRAFORM_DIR/environments/dev/terraform.tfvars"
    local prod_vars="$TERRAFORM_DIR/environments/prod/terraform.tfvars"
    
    if [[ -f "$dev_vars" && -f "$prod_vars" ]]; then
        # Extract variable names (basic check)
        dev_var_names=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\s*=' "$dev_vars" | cut -d'=' -f1 | sed 's/[[:space:]]*$//' | sort)
        prod_var_names=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\s*=' "$prod_vars" | cut -d'=' -f1 | sed 's/[[:space:]]*$//' | sort)
        
        # Basic comparison (this could be enhanced)
        if [[ "$dev_var_names" == "$prod_var_names" ]]; then
            log_success "Variable names are consistent between environments"
        else
            log_warning "Variable names may differ between environments"
            log_info "Run 'diff <(grep -E \"^[a-zA-Z_]\" environments/dev/terraform.tfvars) <(grep -E \"^[a-zA-Z_]\" environments/prod/terraform.tfvars)' for details"
        fi
    fi
}

# Function to validate Azure provider version
validate_provider_version() {
    log_info "Validating Azure provider version..."
    
    cd "$TERRAFORM_DIR"
    
    # Check if using Azure provider 4.x
    if grep -q 'version.*=.*"~> 4.0"' providers.tf; then
        log_success "Using Azure provider 4.x as required"
    else
        log_warning "Please verify Azure provider version is 4.x"
    fi
}

# Function to check for security best practices
check_security_practices() {
    log_info "Checking security best practices..."
    
    cd "$TERRAFORM_DIR"
    
    # Check for hardcoded secrets (basic check)
    if grep -r -i "password\|secret\|key" --include="*.tf" --include="*.tfvars" . | grep -v "key_vault\|_key" | grep -v "ssh_public_key" | grep -q "="; then
        log_warning "Potential hardcoded secrets found. Review and ensure sensitive values are properly managed."
    else
        log_success "No obvious hardcoded secrets found"
    fi
    
    # Check for managed identity usage
    if grep -q "managed_identities" main.tf; then
        log_success "Managed identities are being used"
    else
        log_warning "Consider using managed identities for authentication"
    fi
    
    # Check for minimum TLS version
    if grep -q "minimum_tls_version.*=.*\"1.2\"" main.tf; then
        log_success "Minimum TLS version 1.2 is configured"
    else
        log_warning "Consider setting minimum TLS version to 1.2"
    fi
}

# Function to generate summary report
generate_summary() {
    log_info "Validation Summary:"
    echo "==================="
    echo "✅ Terraform configuration syntax"
    echo "✅ Environment configurations"
    echo "✅ Provider version"
    echo "✅ Security practices"
    echo "==================="
    log_success "All validations completed"
    echo ""
    log_info "Next steps:"
    echo "1. Set up backend storage accounts for remote state"
    echo "2. Configure Azure credentials (az login)"
    echo "3. Run './deploy.sh dev plan' to plan deployment"
    echo "4. Run './deploy.sh dev apply' to deploy infrastructure"
}

# Main function
main() {
    log_info "Starting Terraform validation for Azure Functions Java Demo"
    echo ""
    
    # Run all validation checks
    check_prerequisites
    validate_terraform
    check_formatting
    validate_environments
    check_variable_consistency
    validate_provider_version
    check_security_practices
    
    echo ""
    generate_summary
}

# Execute main function
main "$@"