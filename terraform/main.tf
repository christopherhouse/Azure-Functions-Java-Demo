# Main Terraform configuration for Azure Functions Java Demo Infrastructure

# Azure Naming Module for consistent resource naming
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.0"

  prefix = [var.workload, var.environment]
  suffix = var.suffix != "" ? [var.suffix] : []
}

# Resource Group
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = ">= 0.2.0"

  name                = var.prefix != "" ? "${var.prefix}-${module.naming.resource_group.name}" : module.naming.resource_group.name
  location            = var.location
  enable_telemetry    = var.enable_telemetry
  
  tags = var.tags
}

# Log Analytics Workspace for centralized logging
module "log_analytics" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = ">= 0.3.0"

  name                = var.prefix != "" ? "${var.prefix}-${module.naming.log_analytics_workspace.name}" : module.naming.log_analytics_workspace.name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry

  log_analytics_workspace_retention_in_days = var.log_analytics_retention_days
  log_analytics_workspace_sku               = "PerGB2018"

  tags = var.tags
}

# Application Insights for Function App monitoring
module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = ">= 0.2.0"

  name                = var.prefix != "" ? "${var.prefix}-${module.naming.application_insights.name}" : module.naming.application_insights.name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry

  application_type                = "web"
  workspace_resource_id          = module.log_analytics.resource.id
  retention_in_days              = var.application_insights_retention_days
  disable_ip_masking             = false
  local_authentication_disabled = false

  tags = var.tags
}

# User Assigned Managed Identity for Function App
module "user_assigned_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = ">= 0.2.0"

  name                = var.prefix != "" ? "${var.prefix}-${module.naming.user_assigned_identity.name}" : module.naming.user_assigned_identity.name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry

  tags = var.tags
}

# Storage Account for Function App
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = ">= 0.6.0"

  name                = var.prefix != "" ? "${var.prefix}${module.naming.storage_account.name_unique}" : module.naming.storage_account.name_unique
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry

  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = "TLS1_2"
  
  # Enable secure access
  https_traffic_only_enabled    = true
  public_network_access_enabled = true
  shared_access_key_enabled     = true

  # Configure managed identity access
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.user_assigned_identity.resource.id]
  }

  # Network rules
  network_rules = {
    default_action = "Allow"
    bypass         = ["AzureServices"]
    ip_rules       = var.allowed_ip_ranges
  }

  # Diagnostic settings
  diagnostic_settings_storage_account = var.enable_diagnostic_settings ? {
    default = {
      name                  = "diag-storage"
      workspace_resource_id = module.log_analytics.resource.id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  } : {}

  tags = var.tags

  depends_on = [module.user_assigned_identity]
}

# Service Bus Namespace with topics and subscriptions
module "service_bus" {
  source  = "Azure/avm-res-servicebus-namespace/azurerm"
  version = ">= 0.3.0"

  name                = var.prefix != "" ? "${var.prefix}-${module.naming.servicebus_namespace.name}" : module.naming.servicebus_namespace.name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry

  sku                           = var.service_bus_sku
  capacity                      = var.service_bus_sku == "Premium" ? 1 : null
  public_network_access_enabled = true
  minimum_tls_version           = var.minimum_tls_version

  # Configure managed identities
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.user_assigned_identity.resource.id]
  }

  # Configure topics and subscriptions
  topics = var.service_bus_topics

  # Diagnostic settings
  diagnostic_settings = var.enable_diagnostic_settings ? {
    default = {
      name                  = "diag-servicebus"
      workspace_resource_id = module.log_analytics.resource.id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  } : {}

  tags = var.tags

  depends_on = [module.user_assigned_identity]
}

# App Service Plan for Function App
module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = ">= 0.2.0"

  name                = var.prefix != "" ? "${var.prefix}-${module.naming.app_service_plan.name}" : module.naming.app_service_plan.name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  enable_telemetry    = var.enable_telemetry

  os_type                      = var.function_app_os_type
  sku_name                     = var.function_app_sku
  worker_count                 = var.function_app_sku == "Y1" ? null : 1
  zone_balancing_enabled       = var.function_app_sku != "Y1" ? true : false
  per_site_scaling_enabled     = false
  maximum_elastic_worker_count = var.function_app_sku == "Y1" ? null : 10

  tags = var.tags
}

# Function App
module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = ">= 0.17.0"

  kind                     = "functionapp"
  name                     = var.prefix != "" ? "${var.prefix}-${module.naming.function_app.name}" : module.naming.function_app.name
  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  os_type                  = var.function_app_os_type
  service_plan_resource_id = module.app_service_plan.resource_id
  enable_telemetry         = var.enable_telemetry

  # Configure Function App settings
  https_only                           = true
  client_certificate_enabled          = false
  public_network_access_enabled        = true
  ftp_publish_basic_authentication_enabled    = false
  webdeploy_publish_basic_authentication_enabled = false

  # Managed identities - both system and user assigned
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [module.user_assigned_identity.resource.id]
  }

  # Application Insights integration
  application_insights = {
    name                  = module.application_insights.resource.name
    resource_group_name   = module.resource_group.name
    location              = module.resource_group.location
    application_type      = "web"
    workspace_resource_id = module.log_analytics.resource.id
  }

  # Storage account configuration using managed identity
  storage_account_name          = module.storage_account.resource.name
  storage_uses_managed_identity = true
  key_vault_reference_identity_id = module.user_assigned_identity.resource.id

  # Site configuration
  site_config = {
    # Configure the Function App for Java
    application_stack = {
      java = {
        java_version = var.java_version
      }
    }
    
    # Configure always on (not supported on Consumption plan)
    always_on = var.function_app_sku != "Y1" ? var.function_app_always_on : false
    
    # Security settings
    http2_enabled        = true
    minimum_tls_version  = var.minimum_tls_version
    ftps_state          = "Disabled"
    
    # Configure IP restrictions if provided
    ip_restriction = length(var.allowed_ip_ranges) > 0 ? {
      for idx, ip_range in var.allowed_ip_ranges : "rule_${idx}" => {
        action     = "Allow"
        name       = "Allow_${idx}"
        priority   = 100 + idx
        ip_address = ip_range
      }
    } : {}

    # Function App specific settings
    runtime_scale_monitoring_enabled = var.function_app_sku != "Y1" ? true : false
    use_32_bit_worker                = false
    websockets_enabled               = false
    vnet_route_all_enabled          = false
  }

  # Application settings for Function App
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "java"
    FUNCTIONS_EXTENSION_VERSION = "~4"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    
    # Application Insights
    APPINSIGHTS_INSTRUMENTATIONKEY        = module.application_insights.resource.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.application_insights.resource.connection_string
    
    # Service Bus connection using managed identity
    ServiceBusConnection__fullyQualifiedNamespace = "${module.service_bus.resource.name}.servicebus.windows.net"
    ServiceBusConnection__credential               = "managedidentity"
    ServiceBusConnection__clientId                 = module.user_assigned_identity.resource.client_id
    
    # Storage account settings
    AzureWebJobsStorage__accountName = module.storage_account.resource.name
    AzureWebJobsStorage__credential  = "managedidentity"
    AzureWebJobsStorage__clientId    = module.user_assigned_identity.resource.client_id
    
    # Java specific settings
    JAVA_OPTS = "-Djava.net.preferIPv4Stack=true"
  }

  # Diagnostic settings
  diagnostic_settings = var.enable_diagnostic_settings ? {
    default = {
      name                  = "diag-functionapp"
      workspace_resource_id = module.log_analytics.resource.id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  } : {}

  tags = var.tags

  depends_on = [
    module.app_service_plan,
    module.storage_account,
    module.service_bus,
    module.application_insights,
    module.user_assigned_identity
  ]
}

# RBAC assignments for managed identity to access Service Bus
resource "azurerm_role_assignment" "function_app_service_bus_sender" {
  scope                = module.service_bus.resource.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.user_assigned_identity.resource.principal_id
  
  depends_on = [module.service_bus, module.user_assigned_identity]
}

resource "azurerm_role_assignment" "function_app_service_bus_receiver" {
  scope                = module.service_bus.resource.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.user_assigned_identity.resource.principal_id
  
  depends_on = [module.service_bus, module.user_assigned_identity]
}

# RBAC assignment for managed identity to access storage account
resource "azurerm_role_assignment" "function_app_storage_blob_data_owner" {
  scope                = module.storage_account.resource.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = module.user_assigned_identity.resource.principal_id
  
  depends_on = [module.storage_account, module.user_assigned_identity]
}

resource "azurerm_role_assignment" "function_app_storage_account_contributor" {
  scope                = module.storage_account.resource.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = module.user_assigned_identity.resource.principal_id
  
  depends_on = [module.storage_account, module.user_assigned_identity]
}

# Also assign roles to the system-assigned identity
resource "azurerm_role_assignment" "function_app_system_service_bus_sender" {
  scope                = module.service_bus.resource.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.function_app.identity_principal_id
  
  depends_on = [module.service_bus, module.function_app]
}

resource "azurerm_role_assignment" "function_app_system_service_bus_receiver" {
  scope                = module.service_bus.resource.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.function_app.identity_principal_id
  
  depends_on = [module.service_bus, module.function_app]
}

resource "azurerm_role_assignment" "function_app_system_storage_blob_data_owner" {
  scope                = module.storage_account.resource.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = module.function_app.identity_principal_id
  
  depends_on = [module.storage_account, module.function_app]
}

# Random wait to ensure RBAC propagation
resource "time_sleep" "rbac_propagation" {
  create_duration = "60s"
  
  depends_on = [
    azurerm_role_assignment.function_app_service_bus_sender,
    azurerm_role_assignment.function_app_service_bus_receiver,
    azurerm_role_assignment.function_app_storage_blob_data_owner,
    azurerm_role_assignment.function_app_storage_account_contributor,
    azurerm_role_assignment.function_app_system_service_bus_sender,
    azurerm_role_assignment.function_app_system_service_bus_receiver,
    azurerm_role_assignment.function_app_system_storage_blob_data_owner
  ]
}