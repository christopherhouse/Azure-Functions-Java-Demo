# Environment Configuration
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US 2"
}

variable "resource_group_name" {
  description = "Name of the resource group (will be prefixed with naming convention)"
  type        = string
  default     = "azure-functions-java-demo"
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

# Function App Configuration
variable "function_app_sku" {
  description = "SKU for the Function App service plan"
  type        = string
  default     = "Y1" # Consumption plan
  validation {
    condition = contains([
      "Y1",      # Consumption
      "EP1",     # Premium v3 - Small
      "EP2",     # Premium v3 - Medium
      "EP3",     # Premium v3 - Large
      "I1v2",    # Isolated v2 - Small
      "I2v2",    # Isolated v2 - Medium
      "I3v2"     # Isolated v2 - Large
    ], var.function_app_sku)
    error_message = "SKU must be one of: Y1 (Consumption), EP1/EP2/EP3 (Premium), I1v2/I2v2/I3v2 (Isolated)."
  }
}

variable "function_app_os_type" {
  description = "Operating system type for Function App"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.function_app_os_type)
    error_message = "OS type must be Linux or Windows."
  }
}

variable "java_version" {
  description = "Java version for the Function App"
  type        = string
  default     = "11"
  validation {
    condition     = contains(["11", "17"], var.java_version)
    error_message = "Java version must be 11 or 17."
  }
}

# Service Bus Configuration
variable "service_bus_sku" {
  description = "SKU for Service Bus namespace"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.service_bus_sku)
    error_message = "Service Bus SKU must be Basic, Standard, or Premium."
  }
}

variable "service_bus_topics" {
  description = "Service Bus topics configuration"
  type = map(object({
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
  default = {
    received-orders = {
      max_size_in_megabytes        = 1024
      requires_duplicate_detection = false
      enable_partitioning          = true
      subscriptions = {
        processing = {
          max_delivery_count                   = 10
          requires_session                     = false
          dead_lettering_on_message_expiration = true
        }
      }
    }
  }
}

# Storage Account Configuration
variable "storage_account_tier" {
  description = "Performance tier for storage account"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  description = "Replication type for storage account"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

# Monitoring Configuration
variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "application_insights_retention_days" {
  description = "Application Insights retention in days"
  type        = number
  default     = 90
  validation {
    condition     = var.application_insights_retention_days >= 30 && var.application_insights_retention_days <= 730
    error_message = "Application Insights retention must be between 30 and 730 days."
  }
}

# Security Configuration
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for all resources"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for Function App access"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for resources"
  type        = bool
  default     = false
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

variable "function_app_always_on" {
  description = "Enable always on for Function App (not supported on Consumption plan)"
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for Function App"
  type        = string
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}