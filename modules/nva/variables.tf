variable "rgname" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "availabilitysetid" {
  type = string
}

variable "countindex" {
  type = string
}

variable "nvavalues" {
  type = map(any)
}

variable "intbackendpoolid" {
  type = string
}

variable "extbackendpoolid" {
  type = string
}

variable "bootdiagsname" {
  description = "Name of the storage account to store boot diagnostics"
  type        = string
}
