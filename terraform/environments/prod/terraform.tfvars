# Production Environment Configuration

# Environment Configuration
environment = "prod"
location    = "East US 2"
workload    = "azfuncjava"
prefix      = ""
suffix      = ""

# Monitoring Configuration
monitoring_config = {
  log_analytics = {
    retention_in_days = 90    # Extended retention for production
    sku              = "PerGB2018"
  }
  
  application_insights = {
    application_type              = "web"
    retention_in_days             = 180   # Extended retention for production
    disable_ip_masking            = false
    local_authentication_disabled = false
  }
}

# Storage Account Configuration
storage_config = {
  account_tier                = "Standard"
  account_replication_type    = "GRS"  # Geo redundancy for production
  min_tls_version             = "TLS1_2"
  https_traffic_only_enabled  = true
  public_network_access_enabled = true
  shared_access_key_enabled   = true
  
  network_rules = {
    default_action = "Allow"
    bypass         = ["AzureServices"]
    ip_rules       = [
      # Add your organization's IP ranges here
      # "203.0.113.0/24",
      # "198.51.100.0/24"
    ]
  }
  
  enable_diagnostic_settings = true
}

# Service Bus Configuration
service_bus_config = {
  enable_telemetry             = true
  sku                          = "Premium"
  capacity                     = 1
  public_network_access_enabled = true
  minimum_tls_version          = "1.2"
  
  topics = {
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
  
  enable_diagnostic_settings = true
}

# Function App Configuration
function_app_config = {
  app_service_plan = {
    os_type                     = "Linux"
    sku_name                    = "EP1"    # Premium plan for production
    worker_count                = 1
    zone_balancing_enabled      = true
    per_site_scaling_enabled    = false
    maximum_elastic_worker_count = 10
  }
  
  function_app = {
    os_type                 = "Linux"
    https_only              = true
    client_certificate_enabled = false
    public_network_access_enabled = true
    ftp_publish_basic_authentication_enabled = false
    webdeploy_publish_basic_authentication_enabled = false
    
    application_insights_type = "web"
    
    storage_uses_managed_identity = true
    
    site_config = {
      java_version = "11"
      always_on = true     # Enable always on for Premium plan
      http2_enabled = true
      minimum_tls_version = "1.2"
      ftps_state = "Disabled"
      allowed_ip_ranges = [
        # Add your organization's IP ranges here
        # "203.0.113.0/24",
        # "198.51.100.0/24"
      ]
      runtime_scale_monitoring_enabled = true
      use_32_bit_worker = false
      websockets_enabled = false
      vnet_route_all_enabled = false
    }
    
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "java"
      FUNCTIONS_EXTENSION_VERSION = "~4"
      WEBSITE_RUN_FROM_PACKAGE = "1"
      
      # Java specific settings
      JAVA_OPTS = "-Djava.net.preferIPv4Stack=true"
    }
    
    enable_diagnostic_settings = true
  }
}

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