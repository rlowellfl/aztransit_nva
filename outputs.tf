output "hubvnetname" {
  value = module.hub-network.hubvnetvalues.name
}

output "hubvnetid" {
  value = module.hub-network.hubvnetvalues.id
}

output "obewlbip" {
  value = module.obew-lb.privateip
}
