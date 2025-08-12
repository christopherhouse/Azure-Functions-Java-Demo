# Naming Module Variables
# This module provides consistent naming for all Azure resources

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

variable "prefix" {
  description = "Optional prefix for resource names"
  type        = string
  default     = ""
}

variable "suffix" {
  description = "Optional suffix for resource names"
  type        = string
  default     = ""
}

variable "random_length" {
  description = "Length of random string for unique names"
  type        = number
  default     = 4
}