# Create Virtual Network (if new)
resource "azurerm_virtual_network" "main" {
  count               = var.vnet_new_or_existing == "new" ? 1 : 0
  name                = var.virtual_network_name
  location            = local.location
  resource_group_name = var.resource_group_name
  address_space       = var.virtual_network_address_prefixes
  tags                = var.tags
}

# Create Subnet 1 - Internet/Public (if new VNet)
resource "azurerm_subnet" "subnet1" {
  count                = var.vnet_new_or_existing == "new" ? 1 : 0
  name                 = var.subnet1_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [var.subnet1_prefix]
}

# Create Subnet 2 - LAN/Private (if new VNet and 2 NICs)
resource "azurerm_subnet" "subnet2" {
  count                = var.vnet_new_or_existing == "new" && var.number_of_nics == "2" ? 1 : 0
  name                 = var.subnet2_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [var.subnet2_prefix]
}

# Create Availability Set (if specified)
resource "azurerm_availability_set" "main" {
  count                        = var.availability_set_name != "None" ? 1 : 0
  name                         = var.availability_set_name
  location                     = local.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = var.availability_set_platform_fault_domain_count
  platform_update_domain_count = var.availability_set_platform_update_domain_count
  managed                      = true
  tags                         = var.tags
}

# Create Network Interface 1 - Internet/Public
resource "azurerm_network_interface" "nic1" {
  name                          = "${var.vm_name}-eth1"
  location                      = local.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = false
  tags                          = var.tags

  ip_configuration {
    name                          = "ipconfig-untrust"
    subnet_id                     = local.subnet1_id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.subnet1
  ]
}

# Create Network Interface 2 - LAN/Private (for 2-NIC deployments)
resource "azurerm_network_interface" "nic2" {
  count                         = var.number_of_nics == "2" ? 1 : 0
  name                          = "${var.vm_name}-eth2"
  location                      = local.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = false
  tags                          = var.tags

  ip_configuration {
    name                          = "ipconfig-trust"
    subnet_id                     = local.subnet2_id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.dc_lan_ip_address
  }

  depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.subnet2
  ]
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "ztna_connector" {
  name                            = var.vm_name
  location                        = local.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  custom_data                     = local.custom_data
  availability_set_id             = local.availability_set_id
  zone                            = var.availability_zone != "None" ? var.availability_zone : null
  tags                            = var.tags

  # Network interfaces
  network_interface_ids = var.number_of_nics == "2" ? [
    azurerm_network_interface.nic1.id,
    azurerm_network_interface.nic2[0].id
  ] : [azurerm_network_interface.nic1.id]

  # OS disk
  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Source image reference (for marketplace image)
  dynamic "source_image_reference" {
    for_each = local.source_image_reference != null ? [local.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  # Custom image ID (for custom image)
  source_image_id = local.source_image_id

  # Plan block (for marketplace image)
  dynamic "plan" {
    for_each = local.plan_config != null ? [local.plan_config] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  depends_on = [
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic2,
    azurerm_availability_set.main
  ]
}
