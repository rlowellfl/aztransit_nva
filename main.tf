/*
LOGIN AZURE SUBSCRIPTION
az login
BEFORE DEPLOYING FWs
Using the AzCLI, accept the offer terms prior to deployment. This only
need to be done once per subscription
```
az vm image terms accept --urn paloaltonetworks:vmseries-flex:byol:latest
```
*/

# Configure Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.1.0"
    }
  }
  /*  backend "azurerm" {
    resource_group_name  = "<rg for terraform state backend storage>"
    storage_account_name = "<storage account for terraform state backend storage>"
    container_name       = "transittfstate"
    key                  = "<storage account key>"
  }
*/
}

/*
# Pull data from the Panorama deployment tfstate file
data "terraform_remote_state" "panorama" {
  backend = "azurerm"
  config = {
    resource_group_name  = "<rg for panorama terraform state backend storage>"
    storage_account_name = "<storage account for terraform state backend storage>"
    container_name       = "panoramatfstate"
    key                  = "<storage account key>"
  }
}
*/

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "network" {
  name     = "rg-${var.environment}-${var.environment}-transit"
  location = var.location
  tags = var.required_tags
}

# Deploy the transit hub virtual network
module "hub-network" {
  source             = "./modules/hub-network"
  rgname             = azurerm_resource_group.network.name
  location           = azurerm_resource_group.network.location
  environment        = var.environment
  hubvnetspace       = var.hubvnetspace
  hubdnsservers      = var.hubdnsservers
  hubtrustsubrange   = var.hubtrustsubrange
  hubuntrustsubrange = var.hubuntrustsubrange
  hubmgmtsubrange    = var.hubmgmtsubrange
  hubgatewayrange    = var.hubgatewayrange
  routeserverrange   = var.routeserverrange
  bastionrange       = var.bastionrange
  allowedips         = var.allowedips
}

#Create an Availavility Set for the Palo Alto NVAs
resource "azurerm_availability_set" "palonva" {
  name                        = "as-${var.environment}-${var.location}-transit-palo"
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
  source       = "./modules/obew-lb"
  rgname       = azurerm_resource_group.network.name
  location     = azurerm_resource_group.network.location
  environment  = var.environment
  trustsubid   = module.hub-network.trustsubid
  hubnetworkid = module.hub-network.hubnetworkid
}

# Create the external load balancer
module "ext-lb" {
  source       = "./modules/ext-lb"
  rgname       = azurerm_resource_group.network.name
  location     = azurerm_resource_group.network.location
  environment  = var.environment
  untrustsubid = module.hub-network.untrustsubid
  hubnetworkid = module.hub-network.hubnetworkid
}

# Create the boot diagnostics storage account
resource "azurerm_storage_account" "bootdiags" {
  name                     = var.bootdiagsname
  resource_group_name      = azurerm_resource_group.network.name
  location                 = azurerm_resource_group.network.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Deploy one or more Palo Alto VM-Series NVAs
module "palo-nva" {
  source            = "./modules/palo-nva"
  rgname            = azurerm_resource_group.network.name
  location          = azurerm_resource_group.network.location
  environment       = var.environment
  availabilitysetid = azurerm_availability_set.palonva.id
  count             = var.palodeploycount
  countindex        = count.index
  palovmsize        = var.palovmsize
  palooffer         = var.palooffer
  palosku           = var.palosku
  paloversion       = var.paloversion
  palonvauser       = var.palonvauser
  palonvapass       = var.palonvapass
  hubnetworkid      = module.hub-network.hubnetworkid
  mgmtsubid         = module.hub-network.mgmtsubid
  untrustsubid      = module.hub-network.untrustsubid
  trustsubid        = module.hub-network.trustsubid
  intbackendpoolid  = module.obew-lb.backendpoolid
  extbackendpoolid  = module.ext-lb.backendpoolid
  bootdiagsname     = azurerm_storage_account.bootdiags.primary_blob_endpoint
}

# Create and associate route tables for the transit hub subnets
module "transit-routes" {
  source            = "./modules/transit-routes"
  rgname            = azurerm_resource_group.network.name
  location          = azurerm_resource_group.network.location
  environment       = var.environment
  extlbip           = module.ext-lb.privateip
  intlbip           = module.obew-lb.privateip
  mgmtsubiprange    = module.hub-network.mgmtsubiprange
  untrustsubiprange = module.hub-network.untrustsubiprange
  trustsubiprange   = module.hub-network.trustsubiprange
  mgmtsubid         = module.hub-network.mgmtsubid
  untrustsubid      = module.hub-network.untrustsubid
  trustsubid        = module.hub-network.trustsubid
}

# Deploy one or more spoke virtual networks
module "spoke-network" {
  for_each       = var.spoke_network
  source         = "./modules/spoke-network"
  location       = var.location
  environment    = var.environment
  rgname         = azurerm_resource_group.network.name
  hubNetworkName = module.hub-network.hubvnetname
  hubNetworkID   = module.hub-network.hubvnetid
  intlbip        = module.obew-lb.privateip
  spokeVnetName  = each.value["spokeVnetName"]
  spokeVnetRange = each.value["spokeVnetRange"]
  spokeSubName   = each.value["spokeSubName"]
  spokeSubRange  = each.value["spokeSubRange"]
}