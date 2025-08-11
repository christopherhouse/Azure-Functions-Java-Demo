variable "storage_config" {
  description = "Configuration for the storage account"
  type = object({
    name                         = string
    location                     = string
    resource_group_name          = string
    enable_telemetry            = bool
    account_tier                = string
    account_replication_type    = string
    min_tls_version             = string
    https_traffic_only_enabled  = bool
    public_network_access_enabled = bool
    shared_access_key_enabled   = bool
    
    # Managed identity configuration
    user_assigned_resource_ids  = list(string)
    
    # Network rules
    network_rules = object({
      default_action = string
      bypass         = list(string)
      ip_rules       = list(string)
    })
    
    # Diagnostic settings
    enable_diagnostic_settings = bool
    log_analytics_workspace_id = string
    
    tags = map(string)
  })
}