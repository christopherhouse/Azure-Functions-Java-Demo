terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }

  backend "azurerm" {
    # Backend configuration will be provided via backend config file or CLI
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  resource_provider_registrations = "none"
  # Use Azure AD authentication for Storage APIs when shared access keys are disabled
  storage_use_azuread = true
  # Toggle OIDC vs Azure CLI/device code auth. In CI we keep OIDC (default true via variable).
  # Locally create a gitignored local.auto.tfvars with use_oidc=false to rely on az login credentials.
  use_oidc = var.use_oidc

  # Optional explicit subscription / tenant pinning for local workflows. Leave blank to auto-detect from az cli context.
  subscription_id = var.subscription_id == "" ? null : var.subscription_id
  tenant_id       = var.tenant_id == "" ? null : var.tenant_id
}

# Get current client configuration
data "azurerm_client_config" "current" {}