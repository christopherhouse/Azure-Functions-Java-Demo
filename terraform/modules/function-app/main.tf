# App Service Plan for Function App
module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = ">= 0.2.0"

  name                = var.function_app_config.app_service_plan.name
  location            = var.function_app_config.app_service_plan.location
  resource_group_name = var.function_app_config.app_service_plan.resource_group_name
  enable_telemetry    = var.function_app_config.app_service_plan.enable_telemetry

  os_type                      = var.function_app_config.app_service_plan.os_type
  sku_name                     = var.function_app_config.app_service_plan.sku_name
  worker_count                 = var.function_app_config.app_service_plan.sku_name == "Y1" ? null : var.function_app_config.app_service_plan.worker_count
  zone_balancing_enabled       = var.function_app_config.app_service_plan.sku_name != "Y1" ? var.function_app_config.app_service_plan.zone_balancing_enabled : false
  per_site_scaling_enabled     = var.function_app_config.app_service_plan.per_site_scaling_enabled
  maximum_elastic_worker_count = var.function_app_config.app_service_plan.sku_name == "Y1" ? null : var.function_app_config.app_service_plan.maximum_elastic_worker_count

  tags = var.function_app_config.app_service_plan.tags
}

# Function App
module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = ">= 0.17.0"

  kind                     = "functionapp"
  name                     = var.function_app_config.function_app.name
  location                 = var.function_app_config.function_app.location
  resource_group_name      = var.function_app_config.function_app.resource_group_name
  os_type                  = var.function_app_config.function_app.os_type
  service_plan_resource_id = module.app_service_plan.resource_id
  enable_telemetry         = var.function_app_config.function_app.enable_telemetry

  # Configure Function App settings
  https_only                                     = var.function_app_config.function_app.https_only
  client_certificate_enabled                     = var.function_app_config.function_app.client_certificate_enabled
  public_network_access_enabled                  = var.function_app_config.function_app.public_network_access_enabled
  ftp_publish_basic_authentication_enabled       = var.function_app_config.function_app.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.function_app_config.function_app.webdeploy_publish_basic_authentication_enabled

  # Managed identities - both system and user assigned
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = var.function_app_config.function_app.user_assigned_resource_ids
  }

  # Application Insights integration
  application_insights = {
    name                  = var.function_app_config.function_app.application_insights_name
    resource_group_name   = var.function_app_config.function_app.application_insights_resource_group_name
    location              = var.function_app_config.function_app.application_insights_location
    application_type      = var.function_app_config.function_app.application_insights_type
    workspace_resource_id = var.function_app_config.function_app.application_insights_workspace_id
  }

  # Storage account configuration using managed identity
  storage_account_name            = var.function_app_config.function_app.storage_account_name
  storage_uses_managed_identity   = var.function_app_config.function_app.storage_uses_managed_identity
  key_vault_reference_identity_id = var.function_app_config.function_app.key_vault_reference_identity_id

  # Site configuration
  site_config = {
    # Configure the Function App for Java
    application_stack = {
      java = {
        java_version = var.function_app_config.function_app.site_config.java_version
      }
    }

    # Configure always on (not supported on Consumption plan)
    always_on = var.function_app_config.app_service_plan.sku_name != "Y1" ? var.function_app_config.function_app.site_config.always_on : false

    # Security settings
    http2_enabled       = var.function_app_config.function_app.site_config.http2_enabled
    minimum_tls_version = var.function_app_config.function_app.site_config.minimum_tls_version
    ftps_state          = var.function_app_config.function_app.site_config.ftps_state

    # Configure IP restrictions if provided
    ip_restriction = length(var.function_app_config.function_app.site_config.allowed_ip_ranges) > 0 ? {
      for idx, ip_range in var.function_app_config.function_app.site_config.allowed_ip_ranges : "rule_${idx}" => {
        action     = "Allow"
        name       = "Allow_${idx}"
        priority   = 100 + idx
        ip_address = ip_range
      }
    } : {}

    # Function App specific settings
    runtime_scale_monitoring_enabled = var.function_app_config.app_service_plan.sku_name != "Y1" ? var.function_app_config.function_app.site_config.runtime_scale_monitoring_enabled : false
    use_32_bit_worker                = var.function_app_config.function_app.site_config.use_32_bit_worker
    websockets_enabled               = var.function_app_config.function_app.site_config.websockets_enabled
    vnet_route_all_enabled           = var.function_app_config.function_app.site_config.vnet_route_all_enabled
  }

  # Application settings for Function App
  app_settings = var.function_app_config.function_app.app_settings

  # Diagnostic settings
  diagnostic_settings = var.function_app_config.function_app.enable_diagnostic_settings ? {
    default = {
      name                  = "diag-functionapp"
      workspace_resource_id = var.function_app_config.function_app.log_analytics_workspace_id
      enabled_log = [
        {
          category = "FunctionAppLogs"
          retention_policy = {
            enabled = false
            days    = 0
          }
        },
        {
          category = "AppServiceAuditLogs"
          retention_policy = {
            enabled = false
            days    = 0
          }
        },
        {
          category = "AppServiceHTTPLogs"
          retention_policy = {
            enabled = false
            days    = 0
          }
        }
      ]
      enabled_metric = [
        {
          category = "AllMetrics"
          retention_policy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  } : {}

  tags = var.function_app_config.function_app.tags

  depends_on = [module.app_service_plan]
}