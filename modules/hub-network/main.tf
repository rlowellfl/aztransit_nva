# Create NSGs
resource "azurerm_network_security_group" "palomgmt" {
  name                = "nsg-${var.environment}-${var.location}-transit-palomgmt"
  location            = var.location
  resource_group_name = var.rgname

  security_rule {
    name                       = "HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowedips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowedips
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "default" {
  name                = "nsg-${var.environment}-${var.location}-transit-default"
  location            = var.location
  resource_group_name = var.rgname
}

# Create the transit hub virtual network
resource "azurerm_virtual_network" "transithub" {
  name                = "vnet-${var.environment}-${var.location}-transit"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = var.hubvnetspace
  dns_servers         = var.hubdnsservers
}

# Create transit hub subnets and  associate network security groups
resource "azurerm_subnet" "palomgmt" {
  name                 = "palomgmt"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubmgmtsubrange
}

resource "azurerm_subnet_network_security_group_association" "palomgmt" {
  subnet_id                 = azurerm_subnet.palomgmt.id
  network_security_group_id = azurerm_network_security_group.palomgmt.id
}

resource "azurerm_subnet" "untrust" {
  name                 = "untrust"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubuntrustsubrange
}

resource "azurerm_subnet_network_security_group_association" "untrust" {
  subnet_id                 = azurerm_subnet.untrust.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet" "trust" {
  name                 = "trust"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubtrustsubrange
}

resource "azurerm_subnet_network_security_group_association" "trust" {
  subnet_id                 = azurerm_subnet.trust.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubgatewayrange
}

resource "azurerm_subnet" "routeserver" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.routeserverrange
}