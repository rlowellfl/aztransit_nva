#Create Transit VNET UDRs (Route Tables)
#Mgmt Subnet
resource "azurerm_route_table" "mgmt" {
  name                          = "rt-${var.environment}-${var.location}-transit-mgmt"
  location                      = var.location
  resource_group_name           = var.rgname
  disable_bgp_route_propagation = false

  route {
    name           = "udr-untrust-blackhole"
    address_prefix = var.untrustsubiprange
    next_hop_type  = "None"
  }
  route {
    name                   = "udr-transit-${var.environment}"
    address_prefix         = var.mgmtsubiprange
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.intlbip
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
#Route table for public subnet
resource "azurerm_route_table" "untrust" {
  name                          = "rt-${var.environment}-${var.location}-transit-untrust"
  location                      = var.location
  resource_group_name           = var.rgname
  disable_bgp_route_propagation = false

  route {
    name           = "udr-mgmt-blackhole"
    address_prefix = var.mgmtsubiprange
    next_hop_type  = "None"
  }
  route {
    name           = "udr-trust-blackhole"
    address_prefix = var.trustsubiprange
    next_hop_type  = "None"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
#Route table for private subnet
resource "azurerm_route_table" "trust" {
  name                          = "rt-${var.environment}-${var.location}-transit-trust"
  location                      = var.location
  resource_group_name           = var.rgname
  disable_bgp_route_propagation = false

  route {
    name           = "udr-untrust-blackhole"
    address_prefix = var.untrustsubiprange
    next_hop_type  = "None"
  }
  route {
    name                   = "udr-default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.intlbip
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#Transit VNET Route-Tables -> Subnet Associations
resource "azurerm_subnet_route_table_association" "mgmt" {
  subnet_id      = var.mgmtsubid
  route_table_id = azurerm_route_table.mgmt.id
}
resource "azurerm_subnet_route_table_association" "untrust" {
  subnet_id      = var.untrustsubid
  route_table_id = azurerm_route_table.untrust.id
}
resource "azurerm_subnet_route_table_association" "trust" {
  subnet_id      = var.trustsubid
  route_table_id = azurerm_route_table.trust.id
}