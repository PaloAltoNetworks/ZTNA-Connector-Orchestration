###
# compute.tf outputs
###

output "vm_id" {
  description = "The ID of the ZTNA Connector virtual machine"
  value       = azurerm_linux_virtual_machine.ztna_connector.id
}

output "vm_name" {
  description = "The name of the ZTNA Connector virtual machine"
  value       = azurerm_linux_virtual_machine.ztna_connector.name
}

output "vm_private_ip" {
  description = "The primary private IP address of the ZTNA Connector"
  value       = azurerm_network_interface.nic1.private_ip_address
}

output "nic1_id" {
  description = "The ID of the primary network interface (Internet/Public)"
  value       = azurerm_network_interface.nic1.id
}

output "nic1_private_ip" {
  description = "The private IP address of NIC1 (Internet/Public)"
  value       = azurerm_network_interface.nic1.private_ip_address
}

output "nic2_id" {
  description = "The ID of the secondary network interface (LAN/Private) - only for 2-NIC deployments"
  value       = var.number_of_nics == "2" ? azurerm_network_interface.nic2[0].id : null
}

output "nic2_private_ip" {
  description = "The private IP address of NIC2 (LAN/Private) - only for 2-NIC deployments"
  value       = var.number_of_nics == "2" ? azurerm_network_interface.nic2[0].private_ip_address : null
}

###
# network.tf outputs
###

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = var.vnet_new_or_existing == "new" ? azurerm_virtual_network.main[0].id : data.azurerm_virtual_network.existing[0].id
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = var.virtual_network_name
}

output "subnet1_id" {
  description = "The ID of subnet1 (Internet/Public)"
  value       = local.subnet1_id
}

output "subnet2_id" {
  description = "The ID of subnet2 (LAN/Private) - only for 2-NIC deployments"
  value       = local.subnet2_id
}

###
# availability outputs
###

output "availability_set_id" {
  description = "The ID of the availability set (if created)"
  value       = var.availability_set_name != "None" ? azurerm_availability_set.main[0].id : null
}

output "availability_zone" {
  description = "The availability zone of the VM (if specified)"
  value       = var.availability_zone != "None" ? var.availability_zone : null
}
