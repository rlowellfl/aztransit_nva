output "extlbid" {
  value = azurerm_lb.extlb.id
}

output "backendpoolid" {
  value = azurerm_lb_backend_address_pool.extlb.id
}

output "privateip" {
  value = azurerm_lb.extlb.private_ip_address
}