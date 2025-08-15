variable "function_app_config" {
  description = "Configuration for the Function App and App Service Plan"
  type = object({
    # App Service Plan configuration
    app_service_plan = object({
      name                         = string
      location                     = string
      resource_group_name          = string
      enable_telemetry             = bool
      os_type                      = string
      sku_name                     = string
      worker_count                 = optional(number)
      zone_balancing_enabled       = optional(bool)
      per_site_scaling_enabled     = optional(bool)
      maximum_elastic_worker_count = optional(number)
      tags                         = map(string)
    })

    # Function App configuration
    function_app = object({
      name                                           = string
      location                                       = string
      resource_group_name                            = string
      enable_telemetry                               = bool
      os_type                                        = string
      https_only                                     = bool
      client_certificate_enabled                     = bool
      public_network_access_enabled                  = bool
      ftp_publish_basic_authentication_enabled       = bool
      webdeploy_publish_basic_authentication_enabled = bool

      # Managed identities
      user_assigned_resource_ids = list(string)

      # Application Insights integration
      application_insights_name                = string
      application_insights_resource_group_name = string
      application_insights_location            = string
      application_insights_type                = string
      application_insights_workspace_id        = string

      # Storage account configuration
      storage_account_name            = string
      storage_account_access_key      = optional(string)  # Always null for managed identity
      key_vault_reference_identity_id = string

      # Site configuration
      site_config = object({
        java_version                     = string
        always_on                        = bool
        http2_enabled                    = bool
        minimum_tls_version              = string
        ftps_state                       = string
        allowed_ip_ranges                = list(string)
        runtime_scale_monitoring_enabled = bool
        use_32_bit_worker                = bool
        websockets_enabled               = bool
        vnet_route_all_enabled           = bool
      })

      # Application settings
      app_settings = map(string)

      # Diagnostic settings
      enable_diagnostic_settings = bool
      log_analytics_workspace_id = string

      tags = map(string)
    })
  })
}