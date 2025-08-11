output "storage_account" {
  description = "The storage account resource"
  value       = module.storage_account.resource
}

output "storage_account_id" {
  description = "The resource ID of the storage account"
  value       = module.storage_account.resource.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.resource.name
}