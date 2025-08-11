variable "monitoring_config" {
  description = "Configuration for monitoring resources (Log Analytics and Application Insights)"
  type = object({
    # Log Analytics configuration
    log_analytics = object({
      name                = string
      location            = string
      resource_group_name = string
      enable_telemetry    = bool
      retention_in_days   = number
      sku                 = string
      tags                = map(string)
    })
    
    # Application Insights configuration
    application_insights = object({
      name                           = string
      location                       = string
      resource_group_name           = string
      enable_telemetry              = bool
      application_type              = string
      retention_in_days             = number
      disable_ip_masking            = bool
      local_authentication_disabled = bool
      tags                          = map(string)
    })
  })
}