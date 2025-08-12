# Resource Names Output
# Provides Azure CAF compliant naming for all resources following the pattern:
# [azure resource type abbreviation]-[workloadName]-[environment]-[uniqueString]

# Standard resource names using Azure CAF abbreviations
output "log_analytics_workspace" {
  description = "Log Analytics Workspace name"
  value       = local.resource_names.log_analytics_workspace
}

output "application_insights" {
  description = "Application Insights name" 
  value       = local.resource_names.application_insights
}

output "user_assigned_identity" {
  description = "User Assigned Identity name"
  value       = local.resource_names.user_assigned_identity
}

output "servicebus_namespace" {
  description = "Service Bus Namespace name"
  value       = local.resource_names.servicebus_namespace
}

output "app_service_plan" {
  description = "App Service Plan name"
  value       = local.resource_names.app_service_plan
}

output "function_app" {
  description = "Function App name"
  value       = local.resource_names.function_app
}

# Storage account with special handling for naming constraints
output "storage_account" {
  description = "Storage Account name (unique, lowercase, no hyphens)"
  value       = local.storage_name
}

# Diagnostic setting names
output "diagnostic_names" {
  description = "Standardized diagnostic setting names"
  value       = local.diagnostic_names
}

# Base naming components for reference
output "unique_suffix" {
  description = "Unique suffix for globally unique resources"
  value       = local.unique_suffix
}

# Resource type abbreviations for reference
output "abbreviations" {
  description = "Azure CAF resource type abbreviations used"
  value       = local.resource_abbreviations
}