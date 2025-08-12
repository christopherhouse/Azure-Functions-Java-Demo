# Naming Module Variables
# This module provides Azure CAF compliant naming for all resources

variable "workload" {
  description = "Workload name for naming convention"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prd, local)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prd", "local"], var.environment)
    error_message = "Environment must be one of: dev, test, prd, local."
  }
}

variable "resource_group_name" {
  description = "Resource group name used to generate idempotent unique string"
  type        = string
}