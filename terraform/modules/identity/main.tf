# User Assigned Managed Identity for Function App
module "user_assigned_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = ">= 0.2.0"

  name                = var.identity_config.name
  location            = var.identity_config.location
  resource_group_name = var.identity_config.resource_group_name
  enable_telemetry    = var.identity_config.enable_telemetry

  tags = var.identity_config.tags
}