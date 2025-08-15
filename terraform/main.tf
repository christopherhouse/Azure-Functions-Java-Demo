
# Data source for existing resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Custom Naming Module for Azure CAF compliant resource naming
module "naming" {
  source              = "./modules/naming"
  workload            = var.workload
  environment         = var.environment
  resource_group_name = var.resource_group_name
}

# Monitoring Module (Log Analytics and Application Insights)
module "monitoring" {
  source = "./modules/monitoring"
  monitoring_config = {
    log_analytics = {
      name                = module.naming.log_analytics_workspace
      location            = var.location
      resource_group_name = data.azurerm_resource_group.rg.name
      enable_telemetry    = var.enable_telemetry
      retention_in_days   = var.monitoring_config.log_analytics.retention_in_days
      sku                 = var.monitoring_config.log_analytics.sku
      tags                = var.tags
    }
    application_insights = {
      name                          = module.naming.application_insights
      location                      = var.location
      resource_group_name           = data.azurerm_resource_group.rg.name
      enable_telemetry              = var.enable_telemetry
      application_type              = var.monitoring_config.application_insights.application_type
      retention_in_days             = var.monitoring_config.application_insights.retention_in_days
      disable_ip_masking            = var.monitoring_config.application_insights.disable_ip_masking
      local_authentication_disabled = var.monitoring_config.application_insights.local_authentication_disabled
      tags                          = var.tags
    }
  }
}

# Identity Module (Managed Identity only - RBAC assignments moved to main)
module "identity" {
  source = "./modules/identity"
  identity_config = {
    name                = module.naming.user_assigned_identity
    location            = var.location
    resource_group_name = data.azurerm_resource_group.rg.name
    enable_telemetry    = var.enable_telemetry
    tags                = var.tags
    rbac_assignments = {
      service_bus_scope = ""
      storage_scope     = ""
    }
  }
}

# Storage Module (Storage Account)
module "storage" {
  source                        = "./modules/storage"
  name                          = module.naming.storage_account
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  account_tier                  = var.storage_config.account_tier
  account_replication_type      = var.storage_config.account_replication_type
  min_tls_version               = var.storage_config.min_tls_version
  account_kind                  = "StorageV2"
  public_network_access_enabled = var.storage_config.public_network_access_enabled
  shared_access_key_enabled     = var.storage_config.shared_access_key_enabled
  https_traffic_only_enabled    = var.storage_config.https_traffic_only_enabled
  tags                          = var.tags
  network_rules                 = var.storage_config.network_rules
  diagnostic_name               = module.naming.diagnostic_names.storage_account
  log_analytics_workspace_id    = module.monitoring.log_analytics_id
  rbac_assignments = [
    {
      principal_id         = module.identity.identity_principal_id
      role_definition_name = "Storage Blob Data Owner"
    },
    {
      principal_id         = module.identity.identity_principal_id
      role_definition_name = "Storage Account Contributor"
    }
  ]
  depends_on = [module.identity]
}

# Service Bus Module (Service Bus Namespace, Topics, Subscriptions)
module "service_bus" {
  source = "./modules/service-bus"
  service_bus_config = {
    name                          = module.naming.servicebus_namespace
    location                      = var.location
    resource_group_name           = data.azurerm_resource_group.rg.name
    enable_telemetry              = var.service_bus_config.enable_telemetry
    sku                           = var.service_bus_config.sku
    capacity                      = var.service_bus_config.sku == "Premium" ? var.service_bus_config.capacity : null
    public_network_access_enabled = var.service_bus_config.public_network_access_enabled
    minimum_tls_version           = var.service_bus_config.minimum_tls_version
    user_assigned_resource_ids    = [module.identity.identity_resource_id]
    topics                        = var.service_bus_config.topics
    enable_diagnostic_settings    = var.service_bus_config.enable_diagnostic_settings
    log_analytics_workspace_id    = module.monitoring.log_analytics_id
    tags                          = var.tags
  }
  depends_on = [module.identity]
}

# Function App Module (App Service Plan and Function App)
module "function_app" {
  source = "./modules/function-app"
  function_app_config = {
    app_service_plan = {
      name                         = module.naming.app_service_plan
      location                     = var.location
      resource_group_name          = data.azurerm_resource_group.rg.name
      enable_telemetry             = var.enable_telemetry
      os_type                      = var.function_app_config.app_service_plan.os_type
      sku_name                     = var.function_app_config.app_service_plan.sku_name
      worker_count                 = var.function_app_config.app_service_plan.worker_count
      zone_balancing_enabled       = var.function_app_config.app_service_plan.zone_balancing_enabled
      per_site_scaling_enabled     = var.function_app_config.app_service_plan.per_site_scaling_enabled
      maximum_elastic_worker_count = var.function_app_config.app_service_plan.maximum_elastic_worker_count
      tags                         = var.tags
    }
    function_app = {
      name                                           = module.naming.function_app
      location                                       = var.location
      resource_group_name                            = data.azurerm_resource_group.rg.name
      enable_telemetry                               = var.enable_telemetry
      os_type                                        = var.function_app_config.function_app.os_type
      https_only                                     = var.function_app_config.function_app.https_only
      client_certificate_enabled                     = var.function_app_config.function_app.client_certificate_enabled
      public_network_access_enabled                  = var.function_app_config.function_app.public_network_access_enabled
      ftp_publish_basic_authentication_enabled       = var.function_app_config.function_app.ftp_publish_basic_authentication_enabled
      webdeploy_publish_basic_authentication_enabled = var.function_app_config.function_app.webdeploy_publish_basic_authentication_enabled
      user_assigned_resource_ids                     = [module.identity.identity_resource_id]
      application_insights_name                      = module.monitoring.application_insights.name
      application_insights_resource_group_name       = data.azurerm_resource_group.rg.name
      application_insights_location                  = var.location
      application_insights_type                      = var.function_app_config.function_app.application_insights_type
      application_insights_workspace_id              = module.monitoring.log_analytics_id
      storage_account_name                           = module.storage.storage_account_name
      storage_account_access_key                     = null  # Always null for managed identity
      key_vault_reference_identity_id                = module.identity.identity_resource_id
      site_config                                    = var.function_app_config.function_app.site_config
      app_settings = merge(
        var.function_app_config.function_app.app_settings,
        {
          APPINSIGHTS_INSTRUMENTATIONKEY                = module.monitoring.application_insights_instrumentation_key
          APPLICATIONINSIGHTS_CONNECTION_STRING         = module.monitoring.application_insights_connection_string
          ServiceBusConnection__fullyQualifiedNamespace = "${module.service_bus.service_bus_name}.servicebus.windows.net"
          ServiceBusConnection__credential              = "managedidentity"
          ServiceBusConnection__clientId                = module.identity.identity_client_id
        },
        # AzureWebJobsStorage using system-assigned managed identity
        {
          AzureWebJobsStorage__accountName = module.storage.storage_account_name
          AzureWebJobsStorage__credential  = "managedidentity"
          # Note: No AzureWebJobsStorage__clientId - defaults to system-assigned identity
          # System-assigned identity has all required storage permissions (Storage Blob Data Owner, 
          # Storage Queue Data Contributor, Storage Table Data Contributor)
        }
      )
      enable_diagnostic_settings = var.function_app_config.function_app.enable_diagnostic_settings
      log_analytics_workspace_id = module.monitoring.log_analytics_id
      tags                       = var.tags
    }
  }
  depends_on = [
    module.storage,
    module.service_bus,
    module.monitoring,
    module.identity
  ]
}

# RBAC assignments for user-assigned managed identity to access Service Bus
resource "azurerm_role_assignment" "identity_service_bus_sender" {
  scope                = module.service_bus.service_bus_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.identity.identity_principal_id

  depends_on = [module.service_bus, module.identity]
}

resource "azurerm_role_assignment" "identity_service_bus_receiver" {
  scope                = module.service_bus.service_bus_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.identity.identity_principal_id

  depends_on = [module.service_bus, module.identity]
}

# RBAC assignment for user-assigned managed identity to access storage account
## RBAC assignments for storage are now handled in the storage module

# RBAC assignment for Function App system-assigned identity to access Service Bus
resource "azurerm_role_assignment" "function_app_system_service_bus_sender" {
  scope                = module.service_bus.service_bus_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.function_app.function_app_identity_principal_id

  depends_on = [module.service_bus, module.function_app]
}

resource "azurerm_role_assignment" "function_app_system_service_bus_receiver" {
  scope                = module.service_bus.service_bus_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.function_app.function_app_identity_principal_id

  depends_on = [module.service_bus, module.function_app]
}

# RBAC assignments for Function App system-assigned identity to access storage account
resource "azurerm_role_assignment" "function_app_system_storage_blob_data_owner" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = module.function_app.function_app_identity_principal_id

  depends_on = [module.storage, module.function_app]
}

resource "azurerm_role_assignment" "function_app_system_storage_queue_data_contributor" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = module.function_app.function_app_identity_principal_id

  depends_on = [module.storage, module.function_app]
}

resource "azurerm_role_assignment" "function_app_system_storage_table_data_contributor" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = module.function_app.function_app_identity_principal_id

  depends_on = [module.storage, module.function_app]
}

# Random wait to ensure RBAC propagation
resource "time_sleep" "rbac_propagation" {
  create_duration = "60s"

  depends_on = [
    azurerm_role_assignment.identity_service_bus_sender,
    azurerm_role_assignment.identity_service_bus_receiver,
    azurerm_role_assignment.function_app_system_service_bus_sender,
    azurerm_role_assignment.function_app_system_service_bus_receiver,
    azurerm_role_assignment.function_app_system_storage_blob_data_owner,
    azurerm_role_assignment.function_app_system_storage_queue_data_contributor,
    azurerm_role_assignment.function_app_system_storage_table_data_contributor
  ]
}