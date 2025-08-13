# Resource Group Name (must already exist)
resource_group_name = "RG-JCI-INT-DEMO-DEV"
# Development Environment Configuration

# Environment Configuration
environment = "dev"
location    = "eastus2"
workload    = "azfuncjava"
prefix      = ""
suffix      = ""

# Monitoring Configuration
monitoring_config = {
  log_analytics = {
    retention_in_days = 30
    sku               = "PerGB2018"
  }

  application_insights = {
    application_type              = "web"
    retention_in_days             = 30
    disable_ip_masking            = false
    local_authentication_disabled = false
  }
}

# Storage Account Configuration
storage_config = {
  account_tier                  = "Standard"
  account_replication_type      = "LRS" # Local redundancy for dev
  min_tls_version               = "TLS1_2"
  https_traffic_only_enabled    = true
  public_network_access_enabled = true
  shared_access_key_enabled     = true

  network_rules = {
    default_action = "Allow"
    bypass         = ["AzureServices"]
    ip_rules       = []
  }

  enable_diagnostic_settings = true
}

# Service Bus Configuration
service_bus_config = {
  enable_telemetry              = true
  sku                           = "Standard"
  capacity                      = null
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  topics = {
    received-orders = {
      max_size_in_megabytes        = 1024
      requires_duplicate_detection = false
      enable_partitioning          = true
      enable_express               = false
      support_ordering             = false
      default_message_ttl          = "P14D"
      auto_delete_on_idle          = "P10675199DT2H48M5.4775807S"

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

  enable_diagnostic_settings = true
}

# Function App Configuration
function_app_config = {
  app_service_plan = {
    os_type                      = "Windows"
    sku_name                     = "Y1" # Consumption plan for dev
    worker_count                 = null
    zone_balancing_enabled       = false
    per_site_scaling_enabled     = false
    maximum_elastic_worker_count = null
  }

  function_app = {
    os_type                                        = "Windows"
    https_only                                     = true
    client_certificate_enabled                     = false
    public_network_access_enabled                  = true
    ftp_publish_basic_authentication_enabled       = false
    webdeploy_publish_basic_authentication_enabled = false

    application_insights_type = "web"

    storage_uses_managed_identity = true

    site_config = {
      java_version                     = "11"
      always_on                        = false # Not supported on Consumption plan
      http2_enabled                    = true
      minimum_tls_version              = "1.2"
      ftps_state                       = "Disabled"
      allowed_ip_ranges                = []
      runtime_scale_monitoring_enabled = false
      use_32_bit_worker                = false
      websockets_enabled               = false
      vnet_route_all_enabled           = false
    }

    app_settings = {
      FUNCTIONS_WORKER_RUNTIME    = "java"
      FUNCTIONS_EXTENSION_VERSION = "~4"
      WEBSITE_RUN_FROM_PACKAGE    = "1"

      # Java specific settings
      JAVA_OPTS = "-Djava.net.preferIPv4Stack=true"
    }

    enable_diagnostic_settings = true
  }
}

# Tags
tags = {
  Environment = "dev"
  Project     = "azure-functions-java-demo"
  ManagedBy   = "terraform"
  CostCenter  = "development"
  Owner       = "platform-team"
}

# Advanced Configuration
enable_telemetry = false