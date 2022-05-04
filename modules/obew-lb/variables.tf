variable "rgname" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "hubvnet" {
  type = map(any)
}