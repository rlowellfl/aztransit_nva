output "spokeVNetID" {
  value = azurerm_virtual_network.spoke.id
}

output "spokeNetworkName" {
  value = azurerm_virtual_network.spoke.name
}

output "spokeSubnetName" {
  value = azurerm_subnet.subnet.name
}

output "spokeSubnetRange" {
  value = var.spokeSubRange
}