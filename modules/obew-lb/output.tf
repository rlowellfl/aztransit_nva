output "obewilbid" {
  value = azurerm_lb.obewilb.id
}

output "backendpoolid" {
  value = azurerm_lb_backend_address_pool.obewilb.id
}

output "privateip" {
  value = azurerm_lb.obewilb.private_ip_address
}
