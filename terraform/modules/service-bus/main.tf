# Service Bus Namespace with topics and subscriptions
module "service_bus" {
  source  = "Azure/avm-res-servicebus-namespace/azurerm"
  version = ">= 0.3.0"

  name                = var.service_bus_config.name
  location            = var.service_bus_config.location
  resource_group_name = var.service_bus_config.resource_group_name
  enable_telemetry    = var.service_bus_config.enable_telemetry

  sku                           = var.service_bus_config.sku
  capacity                      = var.service_bus_config.sku == "Premium" ? var.service_bus_config.capacity : null
  public_network_access_enabled = var.service_bus_config.public_network_access_enabled
  minimum_tls_version           = var.service_bus_config.minimum_tls_version

  # Configure managed identities
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = var.service_bus_config.user_assigned_resource_ids
  }

  # Configure topics and subscriptions
  topics = var.service_bus_config.topics

  # Diagnostic settings
  diagnostic_settings = var.service_bus_config.enable_diagnostic_settings ? {
    default = {
      name                  = "diag-servicebus"
      workspace_resource_id = var.service_bus_config.log_analytics_workspace_id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  } : {}

  tags = var.service_bus_config.tags
}