# Create the spoke virtual network
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.environment}-${var.location}-spoke-${var.spokeVnetName}"
  address_space       = var.spokeVnetRange
  location            = var.location
  resource_group_name = var.rgname
}

# Create a subnet within the spoke virtual network
resource "azurerm_subnet" "subnet" {
  name                 = var.spokeSubName
  resource_group_name  = azurerm_virtual_network.spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = var.spokeSubRange
}

#Peer the spoke Vnet to the Hub Vnet
resource "azurerm_virtual_network_peering" "spoketohub" {
  name                         = "${var.spokeVnetName}_to_${var.hubNetworkName}"
  resource_group_name          = var.rgname
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hubNetworkID
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

#Peer the hub Vnet to the Spoke Vnet
resource "azurerm_virtual_network_peering" "spokefromhub" {
  name                         = "${var.spokeVnetName}_from_${var.hubNetworkName}"
  resource_group_name          = var.rgname
  virtual_network_name         = var.hubNetworkName
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

#Create a route table for the Spoke VNet
resource "azurerm_route_table" "routeTable" {
  name                          = "rt-${var.environment}-${var.location}-spoke-${var.spokeVnetName}"
  location                      = var.location
  resource_group_name           = var.rgname
  disable_bgp_route_propagation = true
}

#Create a route for all traffic to point to the internal LB in the Hub Vnet
resource "azurerm_route" "toFirewall" {
  name                   = "To_OBEW_LB"
  resource_group_name    = azurerm_route_table.routeTable.resource_group_name
  route_table_name       = azurerm_route_table.routeTable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.intlbip
}

#Associate the new route table to the spoke network
resource "azurerm_subnet_route_table_association" "routeassoc" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.routeTable.id
}