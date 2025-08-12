# Resource Group Name (must be provided via environment variable)
variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group to deploy resources into. Should be set via TF_VAR_resource_group_name, e.g., from AZURE_RESOURCE_GROUP_NAME."
  type        = string
}
# Environment Configuration
variable "environment" {
  description = "Environment name (dev, test, prod, local)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod", "local"], var.environment)
    error_message = "Environment must be one of: dev, test, prod, local."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US 2"
}

# Naming Configuration
variable "workload" {
  description = "Workload name for naming convention"
  type        = string
  default     = "azfuncjava"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = ""
}

variable "suffix" {
  description = "Suffix for resource names"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "azure-functions-java-demo"
    ManagedBy   = "terraform"
  }
}

# Advanced Configuration
variable "enable_telemetry" {
  description = "Enable telemetry for AVM modules"
  type        = bool
  default     = true
}

# Simplified object configurations for modules

variable "monitoring_config" {
  description = "Configuration for monitoring resources"
  type = object({
    log_analytics = object({
      retention_in_days = number
      sku               = string
    })

    application_insights = object({
      application_type              = string
      retention_in_days             = number
      disable_ip_masking            = bool
      local_authentication_disabled = bool
    })
  })
}

variable "storage_config" {
  description = "Configuration for the storage account"
  type = object({
    account_tier                  = string
    account_replication_type      = string
    min_tls_version               = string
    https_traffic_only_enabled    = bool
    public_network_access_enabled = bool
    shared_access_key_enabled     = bool

    network_rules = object({
      default_action = string
      bypass         = list(string)
      ip_rules       = list(string)
    })

    enable_diagnostic_settings = bool
  })
}

variable "service_bus_config" {
  description = "Configuration for the Service Bus namespace"
  type = object({
    enable_telemetry              = bool
    sku                           = string
    capacity                      = optional(number)
    public_network_access_enabled = bool
    minimum_tls_version           = string

    topics = map(object({
      max_size_in_megabytes                   = optional(number, 1024)
      requires_duplicate_detection            = optional(bool, false)
      default_message_ttl                     = optional(string, "P14D")
      auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")
      enable_partitioning                     = optional(bool, true)
      enable_express                          = optional(bool, false)
      support_ordering                        = optional(bool, false)
      duplicate_detection_history_time_window = optional(string, "PT10M")

      subscriptions = optional(map(object({
        max_delivery_count                        = optional(number, 10)
        lock_duration                             = optional(string, "PT1M")
        requires_session                          = optional(bool, false)
        default_message_ttl                       = optional(string, "P14D")
        dead_lettering_on_message_expiration      = optional(bool, false)
        dead_lettering_on_filter_evaluation_error = optional(bool, true)
        enable_batched_operations                 = optional(bool, true)
        auto_delete_on_idle                       = optional(string, "P10675199DT2H48M5.4775807S")
      })), {})
    }))

    enable_diagnostic_settings = bool
  })
}

variable "function_app_config" {
  description = "Configuration for the Function App and App Service Plan"
  type = object({
    app_service_plan = object({
      os_type                      = string
      sku_name                     = string
      worker_count                 = optional(number)
      zone_balancing_enabled       = optional(bool)
      per_site_scaling_enabled     = optional(bool)
      maximum_elastic_worker_count = optional(number)
    })

    function_app = object({
      os_type                                        = string
      https_only                                     = bool
      client_certificate_enabled                     = bool
      public_network_access_enabled                  = bool
      ftp_publish_basic_authentication_enabled       = bool
      webdeploy_publish_basic_authentication_enabled = bool

      application_insights_type = string

      storage_uses_managed_identity = bool

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

      app_settings = map(string)

      enable_diagnostic_settings = bool
    })
  })
}

# Authentication control (local vs CI)
variable "use_oidc" {
  description = "When true (default) the Azurerm provider will attempt OIDC federation (used in CI). Set to false locally to use Azure CLI / device code auth."
  type        = bool
  default     = true
}

variable "subscription_id" {
  description = "Optional explicit subscription id override for the provider. Leave empty to inherit from az cli context."
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "Optional explicit tenant id override for the provider. Leave empty to inherit from az cli context."
  type        = string
  default     = ""
}