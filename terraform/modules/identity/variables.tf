variable "identity_config" {
  description = "Configuration for the managed identity and RBAC assignments"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    enable_telemetry    = bool
    tags                = map(string)
    
    # RBAC assignments configuration
    rbac_assignments = object({
      service_bus_scope   = string
      storage_scope       = string
    })
  })
}