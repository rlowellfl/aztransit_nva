
# Create Internal LoadBalancer (LB)
resource "azurerm_lb" "obewilb" {
  name                = "ilb-${var.environment}-${var.location}-transit"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "Internal_VIP"
    subnet_id                     = var.trustsubid
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create Internal LoadBalancer Probe
resource "azurerm_lb_probe" "obewilb" {
  #resource_group_name = azurerm_resource_group.rg-networking-prod.name
  loadbalancer_id = azurerm_lb.obewilb.id
  name            = "https-probe"
  port            = 443
}

# Create backend Pool for PA Internal LB
resource "azurerm_lb_backend_address_pool" "obewilb" {
  loadbalancer_id = azurerm_lb.obewilb.id
  name            = "To_PA_Trust"
}

# Create internal PA LB Rule
resource "azurerm_lb_rule" "ilb-transit-prod-01-rule" {
  #resource_group_name            = azurerm_resource_group.rg-networking-prod.name
  loadbalancer_id                = azurerm_lb.obewilb.id
  name                           = "Private-All-Ports"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "Internal_VIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.obewilb.id]
  probe_id                       = azurerm_lb_probe.obewilb.id
}