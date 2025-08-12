# Random ID for unique resource names
resource "random_id" "this" {
  byte_length = var.random_length
}

# Azure Naming Module for standard naming patterns
module "azure_naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.0"
  prefix  = compact([var.prefix, var.workload])
  suffix  = compact([var.environment, var.suffix])
}

# Local values for consistent naming
locals {
  # Common naming pattern for most resources
  common_name_parts = compact([
    var.prefix,
    var.workload,
    var.environment,
    var.suffix
  ])
  
  # Base name for resources
  base_name = join("-", local.common_name_parts)
  
  # Unique suffix for resources that need global uniqueness
  unique_suffix = lower(random_id.this.hex)
  
  # Storage account name (no hyphens, max 24 chars, globally unique)
  storage_name_parts = compact([
    var.prefix != "" ? replace(var.prefix, "-", "") : "",
    replace(var.workload, "-", ""),
    replace(var.environment, "-", ""),
    var.suffix != "" ? replace(var.suffix, "-", "") : ""
  ])
  storage_base_name = join("", local.storage_name_parts)
  storage_name_with_suffix = "${local.storage_base_name}${local.unique_suffix}"
  
  # Truncate storage name to 24 characters if needed
  storage_name = length(local.storage_name_with_suffix) > 24 ? substr(local.storage_name_with_suffix, 0, 24) : local.storage_name_with_suffix
}