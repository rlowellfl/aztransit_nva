variable "rgname" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "spokeVnetName" {
  type = string
}

variable "spokeVnetRange" {
  type = list(string)
}

variable "spokeSubName" {
  type = string
}

variable "spokeSubRange" {
  type = list(string)
}

variable "hubvnet" {
  type = map(any)
}

variable "intlbip" {
  type = string
}