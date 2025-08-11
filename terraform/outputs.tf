# Output values for the infrastructure

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = data.azurerm_resource_group.rg.id
}

# Function App
output "function_app_name" {
  description = "Name of the Function App"
  value       = module.function_app.function_app_name
}

output "function_app_id" {
  description = "ID of the Function App"
  value       = module.function_app.function_app_id
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = try(module.function_app.function_app.default_hostname, null)
}

output "function_app_identity_principal_id" {
  description = "Principal ID of the Function App's system-assigned identity"
  value       = module.function_app.function_app_identity_principal_id
}

# Service Bus
output "service_bus_namespace_name" {
  description = "Name of the Service Bus namespace"
  value       = module.service_bus.service_bus_name
}

output "service_bus_namespace_id" {
  description = "ID of the Service Bus namespace"
  value       = module.service_bus.service_bus_id
}

output "service_bus_namespace_hostname" {
  description = "Hostname of the Service Bus namespace"
  value       = "${module.service_bus.service_bus_name}.servicebus.windows.net"
}

# Storage Account
output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage.storage_account_id
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage.storage_account.primary_blob_endpoint
}

# Application Insights
output "application_insights_name" {
  description = "Name of Application Insights"
  value       = module.monitoring.application_insights.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

# Log Analytics
output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.monitoring.log_analytics.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_id
}

# Managed Identity
output "user_assigned_identity_name" {
  description = "Name of the user-assigned managed identity"
  value       = module.identity.identity.name
}

output "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = module.identity.identity_resource_id
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity"
  value       = module.identity.identity_principal_id
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity"
  value       = module.identity.identity_client_id
}

# App Service Plan
output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = module.function_app.app_service_plan.name
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = module.function_app.app_service_plan_id
}

# Deployment Information
output "deployment_info" {
  description = "Information about the deployment"
  value = {
    environment     = var.environment
    location        = var.location
    workload        = var.workload
    java_version    = var.function_app_config.function_app.site_config.java_version
    function_sku    = var.function_app_config.app_service_plan.sku_name
    service_bus_sku = var.service_bus_config.sku
    deployed_at     = timestamp()
  }
}

# Connection Strings and Configuration for Function App
output "function_app_configuration" {
  description = "Configuration values for Function App deployment"
  value = {
    service_bus_namespace_name = module.service_bus.service_bus_name
    service_bus_connection     = "Endpoint=sb://${module.service_bus.service_bus_name}.servicebus.windows.net/;Authentication=Managed Identity"
    storage_account_name       = module.storage.storage_account_name
    application_insights_key   = module.monitoring.application_insights_instrumentation_key
    managed_identity_client_id = module.identity.identity_client_id
  }
  sensitive = true
}