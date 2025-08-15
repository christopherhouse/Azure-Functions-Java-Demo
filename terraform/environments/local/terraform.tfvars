# Copy this file to local.auto.tfvars (kept out of git) to use Azure CLI authentication instead of OIDC.
# Steps:
# 1. az login
# 2. (optional) az account set --subscription <subscription-id>
# 3. cp terraform/local.example.auto.tfvars terraform/local.auto.tfvars (or create manually)
# 4. Run ./deploy.sh dev plan (or apply)

# Disable OIDC so provider uses CLI token
use_oidc = false

# Optionally pin a subscription explicitly (otherwise provider detects from CLI context)
subscription_id = "47046546-29e0-4be5-bdda-78a53f62b992"
tenant_id       = "76de2d2d-77f8-438d-9a87-01806f2345da"

# Development Environment Configuration

# Environment Configuration
resource_group_name = "RG-JCI-INT-DEMO-DEV"

environment = "local"
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
    os_type                      = "Linux"
    sku_name                     = "Y1" # Consumption plan for dev
    worker_count                 = 1
    zone_balancing_enabled       = false
    per_site_scaling_enabled     = false
    maximum_elastic_worker_count = null
  }

  function_app = {
    os_type                                        = "Linux"
    https_only                                     = true
    client_certificate_enabled                     = false
    public_network_access_enabled                  = true
    ftp_publish_basic_authentication_enabled       = false
    webdeploy_publish_basic_authentication_enabled = false

    application_insights_type = "web"

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
  Environment = "local"
  Project     = "azure-functions-java-demo"
  ManagedBy   = "terraform"
  CostCenter  = "local"
  Owner       = "platform-team"
}

# Advanced Configuration
enable_telemetry = false