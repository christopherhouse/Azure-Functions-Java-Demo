# Function App Module

This module manages the Azure Function App and its hosting infrastructure, including the App Service Plan.

## Resources Created

- App Service Plan
- Function App with Java runtime (Windows)
- Site configuration and application settings

## Input Variables

### function_app_config (required)
A complex object containing the Function App configuration:

```hcl
function_app_config = {
  app_service_plan = object({
    name                         = string
    location                     = string
    resource_group_name         = string
    enable_telemetry            = bool
    os_type                     = string  # "Linux" or "Windows"
    sku_name                    = string  # "Y1", "EP1", "EP2", etc.
    worker_count                = number
    zone_balancing_enabled      = bool
    per_site_scaling_enabled    = bool
    maximum_elastic_worker_count = number
    tags                        = map(string)
  })
  
  function_app = object({
    name                     = string
    location                 = string
    resource_group_name     = string
    enable_telemetry        = bool
    os_type                 = string
    https_only              = bool
    client_certificate_enabled = bool
    public_network_access_enabled = bool
    ftp_publish_basic_authentication_enabled = bool
    webdeploy_publish_basic_authentication_enabled = bool
    
    user_assigned_resource_ids = list(string)
    
    # Application Insights integration
    application_insights_name = string
    application_insights_resource_group_name = string
    application_insights_location = string
    application_insights_type = string
    application_insights_workspace_id = string
    
    # Storage configuration
    storage_account_name = string
    # Note: Always uses managed identity - no access key needed
    key_vault_reference_identity_id = string
    
    # Site configuration
    site_config = object({
      java_version = string  # "11" or "17"
      always_on = bool
      http2_enabled = bool
      minimum_tls_version = string
      ftps_state = string
      allowed_ip_ranges = list(string)
      runtime_scale_monitoring_enabled = bool
      use_32_bit_worker = bool
      websockets_enabled = bool
      vnet_route_all_enabled = bool
    })
    
    app_settings = map(string)
    
    enable_diagnostic_settings = bool
    log_analytics_workspace_id = string
    
    tags = map(string)
  })
}
```

## Outputs

- `app_service_plan` - The App Service Plan resource
- `app_service_plan_id` - Resource ID of the App Service Plan
- `function_app` - The Function App resource
- `function_app_id` - Resource ID of the Function App
- `function_app_identity_principal_id` - Principal ID of the system-assigned identity
- `function_app_name` - Name of the Function App

## Features

- **Java Runtime**: Configured for Java 11/17 on Windows
- **Managed Identity**: Both system-assigned and user-assigned identities
- **Application Insights**: Integrated monitoring and telemetry
- **Security**: HTTPS-only, TLS 1.2 minimum, FTP disabled
- **Scaling**: Supports consumption and premium plans
- **IP Restrictions**: Configurable IP allowlists
- **Diagnostic Settings**: Integrated with Log Analytics

## Usage

```hcl
module "function_app" {
  source = "./modules/function-app"
  
  function_app_config = {
    app_service_plan = {
      name                         = "example-plan"
      location                     = "East US 2"
      resource_group_name         = "example-rg"
      enable_telemetry            = true
      os_type                     = "Windows"
      sku_name                    = "Y1"
      worker_count                = null
      zone_balancing_enabled      = false
      per_site_scaling_enabled    = false
      maximum_elastic_worker_count = null
      tags = {
        Environment = "dev"
      }
    }
    
    function_app = {
      # Function App configuration...
    }
  }
}
```