# Environmental variables

variable "environment" {
  description = "Environment for the deployment. Ex: prod, dev, test, sandbox"
  type        = string
}

variable "location" {
  description = "Location for the deployment"
  type        = string
}

# Tag variables
variable "required_tags" {
  description = "List of required tags to be applied to the resource group. Tags will be inherited by child resources automatically based on Azure policy."
  type        = map(any)
}

# Hub network variable

variable "hubvnet" {
  type = map(any)
}

# Palo Alto NVA variables
variable "bootdiagsname" {
  description = "Name of the storage account to store boot diagnostics"
  type        = string
}

variable "nvavalues" {
  description = "Values for the marketplace Network Virtual Appliance image"
  type        = map(any)
}