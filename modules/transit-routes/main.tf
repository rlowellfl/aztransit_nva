#Create Transit VNET UDRs (Route Tables)
#Mgmt Subnet
resource "azurerm_route_table" "mgmt" {
  name                          = "rt-${var.environment}-${var.location}-transit-mgmt"
  location                      = var.location
  resource_group_name           = var.rgname
  disable_bgp_route_propagation = false

  route {
    name           = "udr-untrust-blackhole"
    address_prefix = "10.2.54.64/28"
    next_hop_type  = "None"
  }
  route {
    name                   = "udr-transit-${var.environment}"
    address_prefix         = "10.2.54.32/28"
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
    address_prefix = "10.2.54.32/28"
    next_hop_type  = "None"
  }
  route {
    name           = "udr-trust-blackhole"
    address_prefix = "10.2.54.48/28"
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
    address_prefix = "10.2.54.64/28"
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
  subnet_id      = "/subscriptions/3ac26373-cca2-40e5-9177-ce25e413a77c/resourceGroups/rg-prod-northcentral-transitnet/providers/Microsoft.Network/virtualNetworks/vnet-prod-northcentral-transit/subnets/mgmt"
  route_table_id = azurerm_route_table.mgmt.id
}
resource "azurerm_subnet_route_table_association" "untrust" {
  subnet_id      = "/subscriptions/3ac26373-cca2-40e5-9177-ce25e413a77c/resourceGroups/rg-prod-northcentral-transitnet/providers/Microsoft.Network/virtualNetworks/vnet-prod-northcentral-transit/subnets/untrust"
  route_table_id = azurerm_route_table.untrust.id
}
resource "azurerm_subnet_route_table_association" "trust" {
  subnet_id      = "/subscriptions/3ac26373-cca2-40e5-9177-ce25e413a77c/resourceGroups/rg-prod-northcentral-transitnet/providers/Microsoft.Network/virtualNetworks/vnet-prod-northcentral-transit/subnets/trust"
  route_table_id = azurerm_route_table.trust.id
}
