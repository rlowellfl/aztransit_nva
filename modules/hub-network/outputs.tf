output "hubvnetvalues" {
  value = {
    name              = azurerm_virtual_network.transithub.name
    id                = azurerm_virtual_network.transithub.id
    mgmtsubid         = azurerm_subnet.mgmt.id
    trustsubid        = azurerm_subnet.trust.id
    untrustsubid      = azurerm_subnet.untrust.id
    mgmtsubiprange    = join("", azurerm_subnet.mgmt.address_prefixes)
    untrustsubiprange = join("", azurerm_subnet.untrust.address_prefixes)
    trustsubiprange   = join("", azurerm_subnet.trust.address_prefixes)
    bastionsubiprange = join("", azurerm_subnet.bastion.address_prefixes)
  }
}