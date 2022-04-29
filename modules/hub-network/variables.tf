variable "environment" {
  type = string
}

variable "rgname" {
  type = string
}

variable "location" {
  type = string
}

variable "hubvnetspace" {
  type = list(string)
}

variable "hubdnsservers" {
  type = list(string)
}

variable "hubtrustsubrange" {
  type = list(string)
}

variable "hubuntrustsubrange" {
  type = list(string)
}

variable "hubmgmtsubrange" {
  type = list(string)
}

variable "hubgatewayrange" {
  type = list(string)
}

variable "routeserverrange" {
  type = list(string)
}

variable "bastionrange" {
  type = list(string)
}

variable "allowedips" {
  type = list(string)
}