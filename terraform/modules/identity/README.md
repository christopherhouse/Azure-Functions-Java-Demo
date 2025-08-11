# Identity Module

This module manages the user-assigned managed identity for the Azure Functions application.

## Resources Created

- User-assigned managed identity

## Input Variables

### identity_config (required)
A complex object containing the identity configuration:

```hcl
identity_config = {
  name                = string  # Name of the managed identity
  location            = string  # Azure region
  resource_group_name = string  # Resource group name
  enable_telemetry    = bool    # Enable AVM module telemetry
  tags                = map(string)  # Resource tags
  
  rbac_assignments = object({
    service_bus_scope = string  # Not used - RBAC handled in main.tf
    storage_scope     = string  # Not used - RBAC handled in main.tf
  })
}
```

## Outputs

- `identity` - The complete managed identity resource
- `identity_resource_id` - Resource ID of the managed identity
- `identity_principal_id` - Principal ID for RBAC assignments
- `identity_client_id` - Client ID for application configuration

## Usage

```hcl
module "identity" {
  source = "./modules/identity"
  
  identity_config = {
    name                = "example-identity"
    location            = "East US 2"
    resource_group_name = "example-rg"
    enable_telemetry    = true
    tags = {
      Environment = "dev"
      Project     = "example"
    }
    rbac_assignments = {
      service_bus_scope = ""
      storage_scope     = ""
    }
  }
}
```

## Notes

- RBAC role assignments are handled in the root module to avoid circular dependencies
- The `rbac_assignments` object is included for interface consistency but not used within the module