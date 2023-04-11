# Create Resource Group
resource "azurerm_resource_group" "network" {
  name     = "rg-${var.environment}-${var.location}-palonva"
  location = var.location
  tags     = var.required_tags
}

#Create an Availavility Set for the NVAs
resource "azurerm_availability_set" "nva" {
  name                        = "as-${var.environment}-${var.location}-transit-nva"
  location                    = azurerm_resource_group.network.location
  resource_group_name         = azurerm_resource_group.network.name
  platform_fault_domain_count = "2"
  managed                     = true
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create the internal OBEW load balancer
module "obew-lb" {
  source      = "./modules/obew-lb"
  rgname      = azurerm_resource_group.network.name
  location    = azurerm_resource_group.network.location
  environment = var.environment
}

# Create the external load balancer
module "ext-lb" {
  source      = "./modules/ext-lb"
  rgname      = azurerm_resource_group.network.name
  location    = azurerm_resource_group.network.location
  environment = var.environment
}

# Create the boot diagnostics storage account
module "bootdiags" {
  source        = "./modules/storageacct"
  bootdiagsname = var.bootdiagsname
  location      = azurerm_resource_group.network.location
  rgname        = azurerm_resource_group.network.name
}

# Deploy one or more Network Virtual Appliances
module "nva" {
  source            = "./modules/nva"
  rgname            = azurerm_resource_group.network.name
  location          = azurerm_resource_group.network.location
  environment       = var.environment
  availabilitysetid = azurerm_availability_set.nva.id
  count             = var.nvavalues.deploycount
  countindex        = count.index
  nvavalues         = var.nvavalues
  intbackendpoolid  = module.obew-lb.backendpoolid
  extbackendpoolid  = module.ext-lb.backendpoolid
  bootdiagsname     = module.bootdiags.primary_blob_endpoint
}

# Create and associate route tables for the transit hub subnets
module "transit-routes" {
  source      = "./modules/transit-routes"
  rgname      = azurerm_resource_group.network.name
  location    = azurerm_resource_group.network.location
  environment = var.environment
  extlbip     = module.ext-lb.privateip
  intlbip     = module.obew-lb.privateip
}
