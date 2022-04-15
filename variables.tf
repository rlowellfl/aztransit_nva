# Environmental variables

variable "environment" {
  description = "Environment for the deployment. Ex: prod, dev, test, sandbox"
  type        = string
}

variable "location" {
  description = "Location for the deployment"
  type        = string
}

# Hub network variables

variable "hubvnetspace" {
  description = "The address space of the transit hub vnet"
  type        = list(string)
}

variable "hubdnsservers" {
  description = "The DNS servers of the transit hub vnet"
  type        = list(string)
}

variable "hubtrustsubrange" {
  description = "Transit hub trust subnet IP range"
  type        = list(string)
}

variable "hubuntrustsubrange" {
  description = "Transit hub untrust subnet IP range"
  type        = list(string)
}

variable "hubmgmtsubrange" {
  description = "Transit hub management subnet IP range"
  type        = list(string)
}

variable "hubgatewayrange" {
  description = "Transit hub GatewaySubnet IP range"
  type        = list(string)
}

variable "routeserverrange" {
  description = "Transit hub RouteServerSubnet IP range"
  type        = list(string)
}

variable "allowedips" {
  description = "List of allowed source IPs to the Palo Alto management public IPs"
  type        = list(string)
}

# Palo Alto NVA variables
variable "bootdiagsname" {
  description = "Name of the storage account to store boot diagnostics"
  type        = string
}

variable "palodeploycount" {
  description = "Number of Palo Alto VM-series appliances to deploy (max 27)"
  type        = string
}

variable "palovmsize" {
  description = "Virtual machine size for the Palo Alto VM series"
  type        = string
}

variable "palooffer" {
  description = "Offer for the Palo Alto VM series."
  type        = string
}

variable "palosku" {
  description = "Determines the Palo Alto licensing model. Options are bundle1, bundle2, or byod"
  type        = string
}

variable "paloversion" {
  description = "Specifies the version of the Palo Alto VM series to deploy"
  type        = string
}

variable "palonvauser" {
  description = "Default username for the Palo Alto VM series."
  type        = string
}

variable "palonvapass" {
  description = "Default password for the Palo Alto VM series. This value should be changed after deployment"
  type        = string
}

# Spoke network variables
variable "spoke_network" {
  description = "Defines spoke networks that branch from the main transit hub."
  type = map(object({
    spokeVnetName  = string
    spokeVnetRange = list(string)
    spokeSubName   = string
    spokeSubRange  = list(string)
    vmName         = string
  }))
}