locals {
  # Location - use provided location or resource group location
  location = var.location != "" ? var.location : data.azurerm_resource_group.main.location

  # VNet resource group name - use existing RG if specified, otherwise use main RG
  vnet_resource_group_name = var.vnet_new_or_existing == "existing" && var.virtual_network_existing_rg_name != "" ? var.virtual_network_existing_rg_name : var.resource_group_name

  # Subnet references
  subnet1_id = var.vnet_new_or_existing == "new" ? azurerm_subnet.subnet1[0].id : data.azurerm_subnet.subnet1[0].id
  subnet2_id = var.number_of_nics == "2" ? (var.vnet_new_or_existing == "new" ? azurerm_subnet.subnet2[0].id : data.azurerm_subnet.subnet2[0].id) : null

  # Availability zone configuration
  availability_zones = var.availability_zone != "None" ? [var.availability_zone] : null

  # Availability set configuration
  availability_set_id = var.availability_set_name != "None" ? azurerm_availability_set.main[0].id : null

  # VM image configuration - marketplace vs custom
  source_image_reference = var.use_marketplace_image ? {
    publisher = var.marketplace_publisher
    offer     = var.marketplace_offer
    sku       = var.marketplace_sku
    version   = var.marketplace_version
  } : null

  source_image_id = var.use_marketplace_image ? null : var.custom_image_id

  # Plan block for marketplace image
  plan_config = var.use_marketplace_image ? {
    name      = var.marketplace_sku
    product   = var.marketplace_offer
    publisher = var.marketplace_publisher
  } : null

  # Extract IP address from CIDR notation for 2-NIC deployment
  dc_lan_ip_address = var.number_of_nics == "2" ? split("/", var.dc_lan_port_private_ip)[0] : null

  # Custom data / cloud-init configuration
  # Format matches the OCI metadata structure
  custom_data_1_nic = base64encode(templatefile("${path.module}/templates/cloud-init-1-nic.tpl", {
    license_key    = var.vm_license_key
    license_secret = var.vm_license_secret
  }))

  custom_data_2_nic = base64encode(templatefile("${path.module}/templates/cloud-init-2-nic.tpl", {
    license_key          = var.vm_license_key
    license_secret       = var.vm_license_secret
    dc_lan_port_ip       = var.dc_lan_port_private_ip
    dc_lan_port_gateway  = var.dc_lan_port_gateway
    dc_lan_port_dns      = var.dc_lan_port_dns
  }))

  custom_data = var.enable_bootstrap ? (var.number_of_nics == "2" ? local.custom_data_2_nic : local.custom_data_1_nic) : null
}
