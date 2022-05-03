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
  value = azurerm_subnet.mgmt.id
}

output "untrustsubid" {
  value = azurerm_subnet.untrust.id
}

output "trustsubid" {
  value = azurerm_subnet.trust.id
}

output "mgmtsubiprange" {
  value = join("", azurerm_subnet.mgmt.address_prefixes)
}

output "untrustsubiprange" {
  value = join("", azurerm_subnet.untrust.address_prefixes)
}

output "trustsubiprange" {
  value = join("", azurerm_subnet.trust.address_prefixes)
}

output "bastionsubiprange" {
  value = join("", azurerm_subnet.bastion.address_prefixes)
}