###
# VM Outputs (from either 1-NIC or 2-NIC module)
###

output "vm_id" {
  description = "The ID of the virtual machine"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].vm_id : module.ztna_connector_2nic[0].vm_id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].vm_name : module.ztna_connector_2nic[0].vm_name
}

output "vm_uuid" {
  description = "The UUID of the virtual machine"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].vm_uuid : module.ztna_connector_2nic[0].vm_uuid
}

output "vm_moid" {
  description = "The managed object ID of the virtual machine"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].vm_moid : module.ztna_connector_2nic[0].vm_moid
}

output "default_ip_address" {
  description = "The default IP address of the virtual machine"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].default_ip_address : module.ztna_connector_2nic[0].default_ip_address
}

output "guest_ip_addresses" {
  description = "All IP addresses assigned to the guest"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].guest_ip_addresses : module.ztna_connector_2nic[0].guest_ip_addresses
}

###
# Network Outputs
###

output "port1_network_id" {
  description = "The network ID for Port1"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].port1_network_id : module.ztna_connector_2nic[0].port1_network_id
}

output "port2_network_id" {
  description = "The network ID for Port2 (2-NIC only)"
  value       = var.number_of_nics == "2" ? module.ztna_connector_2nic[0].port2_network_id : null
}

###
# Infrastructure Outputs
###

output "datastore_id" {
  description = "The datastore ID where the VM is stored"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].datastore_id : module.ztna_connector_2nic[0].datastore_id
}

output "resource_pool_id" {
  description = "The resource pool ID where the VM is deployed"
  value       = var.number_of_nics == "1" ? module.ztna_connector_1nic[0].resource_pool_id : module.ztna_connector_2nic[0].resource_pool_id
}

###
# Configuration Outputs
###

output "number_of_nics" {
  description = "The number of network interfaces deployed"
  value       = var.number_of_nics
}
