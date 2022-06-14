/*

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
      version = "~>3.10.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.10"
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
  name     = "rg-${var.environment}-${var.location}-transit"
  location = var.location
  tags     = var.required_tags
}

# Deploy the transit hub virtual network
module "hub-network" {
  source      = "./modules/hub-network"
  rgname      = azurerm_resource_group.network.name
  location    = azurerm_resource_group.network.location
  environment = var.environment
  hubvnet     = var.hubvnet
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
  hubvnet     = module.hub-network.hubvnetvalues
}

# Create the external load balancer
module "ext-lb" {
  source      = "./modules/ext-lb"
  rgname      = azurerm_resource_group.network.name
  location    = azurerm_resource_group.network.location
  environment = var.environment
  hubvnet     = module.hub-network.hubvnetvalues
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
  hubvnet           = module.hub-network.hubvnetvalues
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
  hubvnet     = module.hub-network.hubvnetvalues
}
