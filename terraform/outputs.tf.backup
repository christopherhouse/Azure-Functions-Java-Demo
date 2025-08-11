# Output values for the infrastructure

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.resource_id
}

# Function App
output "function_app_name" {
  description = "Name of the Function App"
  value       = module.function_app.name
}

output "function_app_id" {
  description = "ID of the Function App"
  value       = module.function_app.resource_id
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = try(module.function_app.resource.default_hostname, null)
}

output "function_app_identity_principal_id" {
  description = "Principal ID of the Function App's system-assigned identity"
  value       = module.function_app.identity_principal_id
}

# Service Bus
output "service_bus_namespace_name" {
  description = "Name of the Service Bus namespace"
  value       = module.service_bus.resource.name
}

output "service_bus_namespace_id" {
  description = "ID of the Service Bus namespace"
  value       = module.service_bus.resource.id
}

output "service_bus_namespace_hostname" {
  description = "Hostname of the Service Bus namespace"
  value       = module.service_bus.resource.name
}

output "service_bus_topics" {
  description = "Service Bus topics information"
  value = {
    for topic_name, topic in module.service_bus.topics : topic_name => {
      name = topic.name
      id   = topic.id
    }
  }
  sensitive = false
}

# Storage Account
output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage_account.resource.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage_account.resource.id
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage_account.resource.primary_blob_endpoint
}

# Application Insights
output "application_insights_name" {
  description = "Name of Application Insights"
  value       = module.application_insights.resource.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.application_insights.resource.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.application_insights.resource.connection_string
  sensitive   = true
}

# Log Analytics
output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.log_analytics.resource.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.log_analytics.resource.id
}

# Managed Identity
output "user_assigned_identity_name" {
  description = "Name of the user-assigned managed identity"
  value       = module.user_assigned_identity.resource.name
}

output "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = module.user_assigned_identity.resource.id
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity"
  value       = module.user_assigned_identity.resource.principal_id
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity"
  value       = module.user_assigned_identity.resource.client_id
}

# App Service Plan
output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = module.app_service_plan.name
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

# Deployment Information
output "deployment_info" {
  description = "Information about the deployment"
  value = {
    environment     = var.environment
    location        = var.location
    workload        = var.workload
    java_version    = var.java_version
    function_sku    = var.function_app_sku
    service_bus_sku = var.service_bus_sku
    deployed_at     = timestamp()
  }
}

# Connection Strings and Configuration for Function App
output "function_app_configuration" {
  description = "Configuration values for Function App deployment"
  value = {
    service_bus_namespace_name = module.service_bus.resource.name
    service_bus_connection     = "Endpoint=sb://${module.service_bus.resource.name}.servicebus.windows.net/;Authentication=Managed Identity"
    storage_account_name       = module.storage_account.resource.name
    application_insights_key   = module.application_insights.resource.instrumentation_key
    managed_identity_client_id = module.user_assigned_identity.resource.client_id
  }
  sensitive = true
}