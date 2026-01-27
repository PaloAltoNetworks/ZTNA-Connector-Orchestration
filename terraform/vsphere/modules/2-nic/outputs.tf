output "vm_id" {
  description = "The ID of the virtual machine"
  value       = vsphere_virtual_machine.ztna_connector.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = vsphere_virtual_machine.ztna_connector.name
}

output "vm_uuid" {
  description = "The UUID of the virtual machine"
  value       = vsphere_virtual_machine.ztna_connector.uuid
}

output "vm_moid" {
  description = "The managed object ID of the virtual machine"
  value       = vsphere_virtual_machine.ztna_connector.moid
}

output "default_ip_address" {
  description = "The default IP address of the virtual machine"
  value       = vsphere_virtual_machine.ztna_connector.default_ip_address
}

output "guest_ip_addresses" {
  description = "All IP addresses assigned to the guest"
  value       = vsphere_virtual_machine.ztna_connector.guest_ip_addresses
}

output "port1_network_id" {
  description = "The network ID for Port1"
  value       = data.vsphere_network.port1.id
}

output "port2_network_id" {
  description = "The network ID for Port2"
  value       = data.vsphere_network.port2.id
}

output "datastore_id" {
  description = "The datastore ID where the VM is stored"
  value       = data.vsphere_datastore.datastore.id
}

output "resource_pool_id" {
  description = "The resource pool ID where the VM is deployed"
  value       = data.vsphere_resource_pool.pool.id
}
