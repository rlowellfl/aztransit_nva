# Create NVA Mgmt subnet Network Security Group
resource "azurerm_network_security_group" "mgmt" {
  name                = "nsg-${var.environment}-${var.location}-transit-mgmt"
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
    source_address_prefixes    = var.hubvnet["allowedips"]
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
    source_address_prefixes    = var.hubvnet["allowedips"]
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create the NVA Trust and Untrust subnet Network Security Group
resource "azurerm_network_security_group" "default" {
  name                = "nsg-${var.environment}-${var.location}-transit-default"
  location            = var.location
  resource_group_name = var.rgname
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create the transit hub virtual network
resource "azurerm_virtual_network" "transithub" {
  name                = "vnet-${var.environment}-${var.location}-transit"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = var.hubvnet["addrspace"]
  dns_servers         = var.hubvnet["dnsservers"]
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create transit hub subnets and associate network security groups
resource "azurerm_subnet" "mgmt" {
  name                 = "mgmt"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubvnet["mgmtsubrange"]
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

resource "azurerm_subnet" "untrust" {
  name                 = "untrust"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubvnet["untrustsubrange"]
}

resource "azurerm_subnet_network_security_group_association" "untrust" {
  subnet_id                 = azurerm_subnet.untrust.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet" "trust" {
  name                 = "trust"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubvnet["trustsubrange"]
}

resource "azurerm_subnet_network_security_group_association" "trust" {
  subnet_id                 = azurerm_subnet.trust.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubvnet["gatewayrange"]
}

resource "azurerm_subnet" "routeserver" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubvnet["routeserverrange"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.transithub.name
  address_prefixes     = var.hubvnet["bastionrange"]
}