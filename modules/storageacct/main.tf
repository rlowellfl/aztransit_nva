resource "azurerm_storage_account" "bootdiags" {
  name                      = var.bootdiagsname
  location                  = var.location
  resource_group_name       = var.rgname
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
  network_rules {
    default_action = "Deny"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
