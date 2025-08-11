#!/usr/bin/env bash
# Terraform deployment script for CI/CD using OIDC (azure/login@v2)
# Usage: ./deploy-ci.sh <environment> [plan|apply|destroy]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR"
ENVIRONMENTS_DIR="$TERRAFORM_DIR/environments"

log() { echo -e "[CI] $*"; }

usage() {
  echo "Usage: $0 <environment> [action]";
  echo "  environment: dev|prod";
  echo "  action: plan|apply|destroy (default: plan)";
}

validate_env() {
  local env=$1
  [[ "$env" =~ ^(dev|prod)$ ]] || { echo "Invalid env: $env"; exit 1; }
  [[ -f "$ENVIRONMENTS_DIR/$env/backend.conf" ]] || { echo "Missing backend.conf"; exit 1; }
  [[ -f "$ENVIRONMENTS_DIR/$env/terraform.tfvars" ]] || { echo "Missing terraform.tfvars"; exit 1; }
}

setup_oidc_env() {
  : "${AZURE_CLIENT_ID:?AZURE_CLIENT_ID is required}"
  : "${AZURE_TENANT_ID:?AZURE_TENANT_ID is required}"
  : "${AZURE_SUBSCRIPTION_ID:?AZURE_SUBSCRIPTION_ID is required}"
  export ARM_USE_OIDC=true
  export ARM_CLIENT_ID="$AZURE_CLIENT_ID"
  export ARM_TENANT_ID="$AZURE_TENANT_ID"
  export ARM_SUBSCRIPTION_ID="$AZURE_SUBSCRIPTION_ID"
  export TF_IN_AUTOMATION=true
}

init() {
  local env=$1
  log "terraform init ($env)"
  (cd "$TERRAFORM_DIR" && terraform init \
    -backend-config="$ENVIRONMENTS_DIR/$env/backend.conf" \
    -reconfigure)
}

plan() {
  local env=$1
  log "terraform plan ($env)"
  (cd "$TERRAFORM_DIR" && terraform plan \
    -var-file="$ENVIRONMENTS_DIR/$env/terraform.tfvars" \
    -out="$ENVIRONMENTS_DIR/$env/terraform.plan")
}

apply() {
  local env=$1
  log "terraform apply ($env)"
  if [[ -f "$ENVIRONMENTS_DIR/$env/terraform.plan" ]]; then
    (cd "$TERRAFORM_DIR" && terraform apply -auto-approve "$ENVIRONMENTS_DIR/$env/terraform.plan")
  else
    (cd "$TERRAFORM_DIR" && terraform apply -auto-approve -var-file="$ENVIRONMENTS_DIR/$env/terraform.tfvars")
  fi
  (cd "$TERRAFORM_DIR" && terraform output)
}

destroy() {
  local env=$1
  log "terraform destroy ($env)"
  (cd "$TERRAFORM_DIR" && terraform destroy -auto-approve -var-file="$ENVIRONMENTS_DIR/$env/terraform.tfvars")
}

main() {
  local env=${1:-}
  local action=${2:-plan}
  [[ -n "$env" ]] || { usage; exit 1; }
  validate_env "$env"
  setup_oidc_env
  init "$env"
  case "$action" in
    plan) plan "$env";;
    apply) apply "$env";;
    destroy) destroy "$env";;
    *) usage; exit 1;;
  esac
  log "Done"
}

main "$@"
