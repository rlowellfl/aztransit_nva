output "palomgmtnicid" {
  value = azurerm_network_interface.vnic0.id
}

output "palountrustnicid" {
  value = azurerm_network_interface.vnic1.id
}

output "palotrustnicid" {
  value = azurerm_network_interface.vnic2.id
}

output "palotrustnicip" {
  value = azurerm_network_interface.vnic2.private_ip_address
}