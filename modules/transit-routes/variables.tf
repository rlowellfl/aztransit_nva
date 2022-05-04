variable "rgname" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "extlbip" {
  type = string
}

variable "intlbip" {
  type = string
}

variable "hubvnet" {
  type = map(any)
}