# variables.tf
variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location for all resources."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "app_service_name_specifier" {
  type        = string
  default     = "asp"
  description = "Specifies the app service name's specifications."
}

variable "app_service_sku_tier" {
  type        = string
  default     = "Shared"
  description = "SKU tier of the app service plan."
}

variable "app_service_sku_size" {
  type        = string
  default     = "D1"
  description = "SKU size of the app service plan."
}

variable "app_service_worker_size" {
  type        = string
  default     = "0"
  description = "Worker size of the app service plan."
}

variable "app_service_worker_count" {
  type        = number
  default     = 1
  description = "Worker count of the app service plan."
}

variable "app_service_stack" {
  type        = string
  default     = "dotnetcore"
  description = "Stack of the app service plan."
}

variable "app_service_kind" {
  type        = string
  default     = "Windows"
  description = "Kind of the app service plan."
}