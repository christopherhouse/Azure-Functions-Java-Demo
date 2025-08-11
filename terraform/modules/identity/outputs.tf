output "identity" {
  description = "The user assigned managed identity resource"
  value       = module.user_assigned_identity.resource
}

output "identity_resource_id" {
  description = "The resource ID of the user assigned managed identity"
  value       = module.user_assigned_identity.resource.id
}

output "identity_principal_id" {
  description = "The principal ID of the user assigned managed identity"
  value       = module.user_assigned_identity.resource.principal_id
}

output "identity_client_id" {
  description = "The client ID of the user assigned managed identity"
  value       = module.user_assigned_identity.resource.client_id
}