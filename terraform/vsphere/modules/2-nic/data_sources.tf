# Data source for vSphere datacenter
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Data source for datastore
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for cluster (if specified)
data "vsphere_compute_cluster" "cluster" {
  count         = var.cluster != "" ? 1 : 0
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for resource pool
data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool != "" ? var.resource_pool : (var.cluster != "" ? "${var.cluster}/Resources" : "Resources")
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for Port1 network
data "vsphere_network" "port1" {
  name          = var.port1_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for Port2 network
data "vsphere_network" "port2" {
  name          = var.port2_network
  datacenter_id = data.vsphere_datacenter.dc.id
}
