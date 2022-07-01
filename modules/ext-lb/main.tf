resource "azurerm_public_ip" "pip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "pip-elb-${var.environment}-${var.location}-transit"
  resource_group_name = var.rgname
  sku                 = "Standard"
}

# Create External Load Balancer (LB)
resource "azurerm_lb" "extlb" {
  name                = "elb-${var.environment}-${var.location}-transit"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "FIP"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create External Load Balancer Probe
resource "azurerm_lb_probe" "extlb" {
  #resource_group_name = azurerm_resource_group.rg-networking-prod.name
  loadbalancer_id = azurerm_lb.extlb.id
  name            = "https-probe"
  port            = 443
}

# Create backend Pool for PA External LB
resource "azurerm_lb_backend_address_pool" "extlb" {
  loadbalancer_id = azurerm_lb.extlb.id
  name            = "To_PA_Untrust"
}

# Create External PA LB Rule
resource "azurerm_lb_rule" "extlb" {
  #resource_group_name            = azurerm_resource_group.rg-networking-prod.name
  loadbalancer_id                = azurerm_lb.extlb.id
  name                           = "HTTPS_Inbound"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "FIP"
  disable_outbound_snat          = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.extlb.id]
  probe_id                       = azurerm_lb_probe.extlb.id
}
