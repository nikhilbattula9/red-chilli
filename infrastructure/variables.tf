variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to deploy the resources."
}

variable "location" {
  type        = string
  description = "The Azure location in which to deploy the resources."
}

variable "environment_tag" {
  type        = string
  description = "The Azure tag for the environment."
  default     = "Pre-prod"
}
