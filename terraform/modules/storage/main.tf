# Storage Account for Function App
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = ">= 0.6.0"

  name                = var.storage_config.name
  location            = var.storage_config.location
  resource_group_name = var.storage_config.resource_group_name
  enable_telemetry    = var.storage_config.enable_telemetry

  account_kind             = "StorageV2"
  account_tier             = var.storage_config.account_tier
  account_replication_type = var.storage_config.account_replication_type
  min_tls_version          = var.storage_config.min_tls_version

  # Enable secure access
  https_traffic_only_enabled    = var.storage_config.https_traffic_only_enabled
  public_network_access_enabled = var.storage_config.public_network_access_enabled
  shared_access_key_enabled     = var.storage_config.shared_access_key_enabled

  # Configure managed identity access
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = var.storage_config.user_assigned_resource_ids
  }

  # Network rules
  network_rules = {
    default_action = var.storage_config.network_rules.default_action
    bypass         = var.storage_config.network_rules.bypass
    ip_rules       = var.storage_config.network_rules.ip_rules
  }

  # Diagnostic settings
  diagnostic_settings_storage_account = var.storage_config.enable_diagnostic_settings ? {
    default = {
      name                  = "diag-storage"
      workspace_resource_id = var.storage_config.log_analytics_workspace_id
      enabled_log = [
        {
          category = "StorageRead"
          retention_policy = {
            enabled = false
            days    = 0
          }
        },
        {
          category = "StorageWrite"
          retention_policy = {
            enabled = false
            days    = 0
          }
        },
        {
          category = "StorageDelete"
          retention_policy = {
            enabled = false
            days    = 0
          }
        }
      ]
      enabled_metric = [
        {
          category = "AllMetrics"
          retention_policy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  } : {}

  tags = var.storage_config.tags
}