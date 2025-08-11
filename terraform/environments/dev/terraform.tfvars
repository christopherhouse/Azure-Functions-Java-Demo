# Development Environment Configuration

# Environment Configuration
environment = "dev"
location    = "East US 2"
workload    = "azfuncjava"
prefix      = ""
suffix      = ""

# Function App Configuration
function_app_sku         = "Y1"     # Consumption plan for dev
function_app_os_type     = "Linux"
java_version            = "11"
function_app_always_on  = false    # Not supported on Consumption plan

# Service Bus Configuration
service_bus_sku = "Standard"

# Define Service Bus topics and subscriptions
service_bus_topics = {
  received-orders = {
    max_size_in_megabytes        = 1024
    requires_duplicate_detection = false
    enable_partitioning          = true
    enable_express              = false
    support_ordering            = false
    default_message_ttl         = "P14D"
    auto_delete_on_idle         = "P10675199DT2H48M5.4775807S"

    subscriptions = {
      processing = {
        max_delivery_count                   = 10
        lock_duration                        = "PT1M"
        requires_session                     = false
        default_message_ttl                  = "P14D"
        dead_lettering_on_message_expiration = true
        enable_batched_operations            = true
        auto_delete_on_idle                  = "P10675199DT2H48M5.4775807S"
      }
    }
  }
}

# Storage Account Configuration
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"  # Local redundancy for dev

# Monitoring Configuration
log_analytics_retention_days     = 30   # Minimum for dev
application_insights_retention_days = 30

# Security Configuration
enable_diagnostic_settings = true
allowed_ip_ranges          = []
enable_private_endpoints   = false
minimum_tls_version       = "1.2"

# Tags
tags = {
  Environment = "dev"
  Project     = "azure-functions-java-demo"
  ManagedBy   = "terraform"
  CostCenter  = "development"
  Owner       = "platform-team"
}

# Advanced Configuration
enable_telemetry = true