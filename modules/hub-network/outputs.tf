output "hubvnetname" {
  value = azurerm_virtual_network.transithub.name
}

output "hubvnetid" {
  value = azurerm_virtual_network.transithub.id
}

output "hubnetworkid" {
  value = azurerm_virtual_network.transithub.id
}

output "mgmtsubid" {
  value = azurerm_subnet.palomgmt.id
}

output "untrustsubid" {
  value = azurerm_subnet.untrust.id
}

output "trustsubid" {
  value = azurerm_subnet.trust.id
}

output "mgmtsubiprange" {
  value = join("", azurerm_subnet.palomgmt.address_prefixes)
}

output "untrustsubiprange" {
  value = join("", azurerm_subnet.untrust.address_prefixes)
}

output "trustsubiprange" {
  value = join("", azurerm_subnet.trust.address_prefixes)
}