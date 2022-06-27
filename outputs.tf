output "hubvnetname" {
  value = module.hub-network.hubvnetvalues.name
}

output "hubvnetid" {
  value = module.hub-network.hubvnetvalues.id
}

output "hubrgname" {
  value = azurerm_resource_group.network.name
}

output "obewlbip" {
  value = module.obew-lb.privateip
}
