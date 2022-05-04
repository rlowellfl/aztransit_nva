
# Create External Load Balancer (LB)
resource "azurerm_lb" "extlb" {
  name                = "elb-${var.environment}-${var.location}-transit"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "VIP"
    subnet_id                     = var.hubvnet.untrustsubid
    private_ip_address_allocation = "Dynamic"
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
  name                           = "Private-All-Ports"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "VIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.extlb.id]
  probe_id                       = azurerm_lb_probe.extlb.id
}