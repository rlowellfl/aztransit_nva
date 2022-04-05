# Create Public IPs
resource "azurerm_public_ip" "mgmtpip" {
  name                = "pip-${var.environment}-${var.location}-transit-mgmt-${var.environment}-${var.countindex}"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "untrustpip" {
  name                = "pip-${var.environment}-${var.location}-transit-untrust-${var.environment}-${var.countindex}"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create VNICs
resource "azurerm_network_interface" "vnic0" {
  name                = "nic-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}-vnic0"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "fw${var.countindex}-mgmt"
    subnet_id                     = var.mgmtsubid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmtpip.id
  }
}

resource "azurerm_network_interface" "vnic1" {
  name                 = "nic-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}-vnic1"
  location             = var.location
  resource_group_name  = var.rgname
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "fw${var.countindex}-untrust"
    subnet_id                     = var.untrustsubid
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.untrustpip.id
  }
}

resource "azurerm_network_interface" "vnic2" {
  name                 = "nic-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}-vnic2"
  location             = var.location
  resource_group_name  = var.rgname
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "fw${var.countindex}-trust"
    subnet_id                     = var.trustsubid
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Palo Alto NVA
resource "azurerm_virtual_machine" "palo-nva" {
  name                = "nva-${var.environment}-${var.location}-transit-obew-${var.countindex}"
  location            = var.location
  resource_group_name = var.rgname
  vm_size             = var.palovmsize
  availability_set_id = var.availabilitysetid

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  plan {
    name      = var.palosku
    publisher = "paloaltonetworks"
    product   = var.palooffer
  }

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = var.palooffer
    sku       = var.palosku
    version   = var.paloversion
  }

  storage_os_disk {
    name              = "disk-os-nva-${var.environment}-${var.location}-transit-obew-${var.countindex}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "63"
  }

  os_profile {
    computer_name  = "nva-${var.environment}-${var.location}-transit-obew-${var.countindex}"
    admin_username = var.palonvauser
    admin_password = var.palonvapass
  }

  primary_network_interface_id = azurerm_network_interface.vnic0.id
  network_interface_ids = [azurerm_network_interface.vnic0.id,
    azurerm_network_interface.vnic1.id,
    azurerm_network_interface.vnic2.id,
  ]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Add the NVA's trusted NIC IP to the internal OBEW load balancer back end pool
resource "azurerm_lb_backend_address_pool_address" "obewilb" {
  name                    = "${azurerm_virtual_machine.palo-nva.name}-trust"
  backend_address_pool_id = var.intbackendpoolid
  virtual_network_id      = var.hubnetworkid
  ip_address              = azurerm_network_interface.vnic2.private_ip_address
}

# Add the NVA's untrusted NIC IP to the external load balancer back end pool
resource "azurerm_lb_backend_address_pool_address" "extlb" {
  name                    = "${azurerm_virtual_machine.palo-nva.name}-trust"
  backend_address_pool_id = var.extbackendpoolid
  virtual_network_id      = var.hubnetworkid
  ip_address              = azurerm_network_interface.vnic1.private_ip_address
}