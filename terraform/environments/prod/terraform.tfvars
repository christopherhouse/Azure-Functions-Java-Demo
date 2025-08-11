# Production Environment Configuration

# Environment Configuration
environment = "prod"
location    = "East US 2"
workload    = "azfuncjava"
prefix      = ""
suffix      = ""

# Function App Configuration
function_app_sku         = "EP1"    # Premium plan for production
function_app_os_type     = "Linux"
java_version            = "11"
function_app_always_on  = true     # Enable always on for Premium plan

# Service Bus Configuration
service_bus_sku = "Premium"

# Define Service Bus topics and subscriptions for production
service_bus_topics = {
  received-orders = {
    max_size_in_megabytes        = 5120  # 5GB for production
    requires_duplicate_detection = true   # Enable duplicate detection
    enable_partitioning          = true
    enable_express              = false  # Don't use express for critical messages
    support_ordering            = true   # Enable ordering for production
    default_message_ttl         = "P7D"  # 7 days TTL
    auto_delete_on_idle         = "P30D" # 30 days idle time
    duplicate_detection_history_time_window = "PT30M"

    subscriptions = {
      processing = {
        max_delivery_count                   = 5     # Lower retry count for production
        lock_duration                        = "PT5M" # Longer lock for production
        requires_session                     = false
        default_message_ttl                  = "P7D"
        dead_lettering_on_message_expiration = true
        enable_batched_operations            = true
        auto_delete_on_idle                  = "P30D"
      }
      
      # Additional subscription for dead letter processing
      dead-letter-processor = {
        max_delivery_count                   = 3
        lock_duration                        = "PT10M"
        requires_session                     = false
        default_message_ttl                  = "P14D"
        dead_lettering_on_message_expiration = false
        enable_batched_operations            = true
        auto_delete_on_idle                  = "P90D"
      }
    }
  }

  # Additional topic for notifications
  order-notifications = {
    max_size_in_megabytes        = 1024
    requires_duplicate_detection = false
    enable_partitioning          = true
    enable_express              = true   # Express for notifications
    support_ordering            = false
    default_message_ttl         = "P1D"  # 1 day TTL for notifications
    
    subscriptions = {
      email-notifications = {
        max_delivery_count                   = 3
        lock_duration                        = "PT1M"
        requires_session                     = false
        default_message_ttl                  = "P1D"
        dead_lettering_on_message_expiration = true
        enable_batched_operations            = true
      }
    }
  }
}

# Storage Account Configuration
storage_account_tier             = "Standard"
storage_account_replication_type = "GRS"  # Geo redundancy for production

# Monitoring Configuration
log_analytics_retention_days     = 90   # Extended retention for production
application_insights_retention_days = 180 # Extended retention for production

# Security Configuration
enable_diagnostic_settings = true
allowed_ip_ranges          = [
  # Add your organization's IP ranges here
  # "203.0.113.0/24",
  # "198.51.100.0/24"
]
enable_private_endpoints   = false  # Can be enabled if VNet integration is needed
minimum_tls_version       = "1.2"

# Tags
tags = {
  Environment = "prod"
  Project     = "azure-functions-java-demo"
  ManagedBy   = "terraform"
  CostCenter  = "production"
  Owner       = "platform-team"
  Backup      = "required"
  Monitoring  = "critical"
}

# Advanced Configuration
enable_telemetry = true