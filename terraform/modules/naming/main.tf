# Generate unique string based on resource group name for idempotency
resource "random_id" "unique_string" {
  keepers = {
    resource_group_name = var.resource_group_name
  }
  byte_length = 4
}

# Local values for Azure CAF compliant naming
locals {
  # Unique suffix based on resource group for idempotency
  unique_suffix = lower(random_id.unique_string.hex)
  
  # Azure CAF resource type abbreviations
  # Standard naming format: [resource-type-abbrev]-[workload]-[environment]-[uniqueString]
  resource_abbreviations = {
    function_app            = "func"
    app_service_plan       = "asp"
    storage_account        = "st"
    servicebus_namespace   = "sbns"
    log_analytics_workspace = "log"
    application_insights   = "appi"
    user_assigned_identity = "id"
  }
  
  # Standard resource names following: [abbrev]-[workload]-[environment]-[unique]
  resource_names = {
    function_app            = "${local.resource_abbreviations.function_app}-${var.workload}-${var.environment}-${local.unique_suffix}"
    app_service_plan       = "${local.resource_abbreviations.app_service_plan}-${var.workload}-${var.environment}-${local.unique_suffix}"
    servicebus_namespace   = "${local.resource_abbreviations.servicebus_namespace}-${var.workload}-${var.environment}-${local.unique_suffix}"
    log_analytics_workspace = "${local.resource_abbreviations.log_analytics_workspace}-${var.workload}-${var.environment}-${local.unique_suffix}"
    application_insights   = "${local.resource_abbreviations.application_insights}-${var.workload}-${var.environment}-${local.unique_suffix}"
    user_assigned_identity = "${local.resource_abbreviations.user_assigned_identity}-${var.workload}-${var.environment}-${local.unique_suffix}"
  }
  
  # Storage account special handling (no hyphens, max 24 chars, globally unique)
  storage_base = "${local.resource_abbreviations.storage_account}${var.workload}${var.environment}${local.unique_suffix}"
  storage_name = length(local.storage_base) > 24 ? substr(local.storage_base, 0, 24) : local.storage_base
  
  # Diagnostic setting names following: diag-[abbrev]-[workload]-[environment]-[unique]
  diagnostic_names = {
    storage_account    = "diag-${local.resource_abbreviations.storage_account}-${var.workload}-${var.environment}-${local.unique_suffix}"
    function_app       = "diag-${local.resource_abbreviations.function_app}-${var.workload}-${var.environment}-${local.unique_suffix}"
    service_bus        = "diag-${local.resource_abbreviations.servicebus_namespace}-${var.workload}-${var.environment}-${local.unique_suffix}"
    log_analytics      = "diag-${local.resource_abbreviations.log_analytics_workspace}-${var.workload}-${var.environment}-${local.unique_suffix}"
    file_service       = "diag-fileservice-${var.workload}-${var.environment}-${local.unique_suffix}"
  }
}