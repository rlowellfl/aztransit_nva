/*

This network virtual appliance deployment module is structured for Palo Alto VM Series firewalls, with 3 NICs
associated (untrust, trust, mgmt). Other NVA images may be substituted in the tfvars file but may require
structural changes to the deployment below based on the image and resource requirements.

*/

# Create Public IPs
resource "azurerm_public_ip" "mgmtpip" {
  name                = "pip-${var.environment}-${var.location}-transit-mgmt-${var.countindex}"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_public_ip" "untrustpip" {
  name                = "pip-${var.environment}-${var.location}-transit-untrust-${var.countindex}"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create VNICs
resource "azurerm_network_interface" "vnic0" {
  name                = "nic-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}-vnic0-test"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "fw${var.countindex}-mgmt"
    subnet_id                     = var.hubvnet.mgmtsubid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmtpip.id
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_interface" "vnic1" {
  name                 = "nic-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}-vnic1-test"
  location             = var.location
  resource_group_name  = var.rgname
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "fw${var.countindex}-untrust"
    subnet_id                     = var.hubvnet.untrustsubid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.untrustpip.id
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_interface" "vnic2" {
  name                 = "nic-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}-vnic2test"
  location             = var.location
  resource_group_name  = var.rgname
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "fw${var.countindex}-trust"
    subnet_id                     = var.hubvnet.trustsubid
    private_ip_address_allocation = "Dynamic"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create NVA
resource "azurerm_linux_virtual_machine" "nva" {
  name                            = "nva-${var.environment}-${var.location}-transit-obew-${var.countindex}"
  location                        = var.location
  resource_group_name             = var.rgname
  size                            = var.nvavalues.vmsize
  availability_set_id             = var.availabilitysetid
  admin_username                  = var.nvavalues.nvauser
  admin_password                  = var.nvavalues.nvapass
  disable_password_authentication = false
  allow_extension_operations      = true

  boot_diagnostics {
    storage_account_uri = var.bootdiagsname
  }

  plan {
    name      = var.nvavalues.sku
    publisher = var.nvavalues.publisher
    product   = var.nvavalues.offer
  }

  source_image_reference {
    publisher = var.nvavalues.publisher
    offer     = var.nvavalues.offer
    sku       = var.nvavalues.sku
    version   = var.nvavalues.version
  }

  os_disk {
    name                 = "disk-os-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "63"
  }

  network_interface_ids = [azurerm_network_interface.vnic0.id,
    azurerm_network_interface.vnic1.id,
    azurerm_network_interface.vnic2.id,
  ]

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Add the NVA's trusted NIC IP to the internal OBEW load balancer back end pool
resource "azurerm_lb_backend_address_pool_address" "obewilb" {
  name                    = "${azurerm_linux_virtual_machine.nva.name}-trust"
  backend_address_pool_id = var.intbackendpoolid
  virtual_network_id      = var.hubvnet.id
  ip_address              = azurerm_network_interface.vnic2.private_ip_address
}

# Add the NVA's untrusted NIC IP to the external load balancer back end pool
resource "azurerm_lb_backend_address_pool_address" "extlb" {
  name                    = "${azurerm_linux_virtual_machine.nva.name}-trust"
  backend_address_pool_id = var.extbackendpoolid
  virtual_network_id      = var.hubvnet.id
  ip_address              = azurerm_network_interface.vnic1.private_ip_address
}
