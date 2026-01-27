# Root module that wraps the 1-NIC and 2-NIC submodules
# This provides a unified interface similar to OCI/Azure/AWS templates

# Deploy 1-NIC ZTNA Connector
module "ztna_connector_1nic" {
  count  = var.number_of_nics == "1" ? 1 : 0
  source = "./modules/1-nic"

  # vSphere infrastructure
  datacenter    = var.datacenter
  cluster       = var.cluster
  resource_pool = var.resource_pool
  datastore     = var.datastore
  folder        = var.folder

  # OVA/OVF deployment
  ovf_local_path       = var.ovf_1nic_local_path
  ovf_remote_url       = var.ovf_1nic_remote_url
  allow_unverified_ssl = var.allow_unverified_ssl

  # VM configuration
  vm_name              = var.vm_name
  num_cpus             = var.num_cpus
  num_cores_per_socket = var.num_cores_per_socket
  memory_mb            = var.memory_mb
  disk_size_gb         = var.disk_size_gb
  disk_thin_provisioned = var.disk_thin_provisioned
  guest_id             = var.guest_id
  firmware             = var.firmware

  # Network
  port1_network      = var.port1_network
  port1_adapter_type = var.port1_adapter_type

  # Port 1 configuration
  port1_type    = var.port1_type
  port1_ip      = var.port1_ip
  port1_subnet  = var.port1_subnet
  port1_gateway = var.port1_gateway
  port1_dns1    = var.port1_dns1
  port1_dns2    = var.port1_dns2

  # Licensing
  license_key    = var.license_key
  license_secret = var.license_secret

  # Advanced configuration
  host1_name = var.host1_name
  host1_ip   = var.host1_ip
  host2_name = var.host2_name
  host2_ip   = var.host2_ip
  host3_name = var.host3_name
  host3_ip   = var.host3_ip

  # Tags and metadata
  tags               = var.tags
  custom_attributes  = var.custom_attributes
  annotation         = var.annotation
}

# Deploy 2-NIC ZTNA Connector
module "ztna_connector_2nic" {
  count  = var.number_of_nics == "2" ? 1 : 0
  source = "./modules/2-nic"

  # vSphere infrastructure
  datacenter    = var.datacenter
  cluster       = var.cluster
  resource_pool = var.resource_pool
  datastore     = var.datastore
  folder        = var.folder

  # OVA/OVF deployment
  ovf_local_path       = var.ovf_2nic_local_path
  ovf_remote_url       = var.ovf_2nic_remote_url
  allow_unverified_ssl = var.allow_unverified_ssl

  # VM configuration
  vm_name              = var.vm_name
  num_cpus             = var.num_cpus
  num_cores_per_socket = var.num_cores_per_socket
  memory_mb            = var.memory_mb
  disk_size_gb         = var.disk_size_gb
  disk_thin_provisioned = var.disk_thin_provisioned
  guest_id             = var.guest_id
  firmware             = var.firmware

  # Network
  port1_network      = var.port1_network
  port2_network      = var.port2_network
  port1_adapter_type = var.port1_adapter_type
  port2_adapter_type = var.port2_adapter_type

  # Port 1 configuration
  port1_type    = var.port1_type
  port1_ip      = var.port1_ip
  port1_subnet  = var.port1_subnet
  port1_gateway = var.port1_gateway
  port1_dns1    = var.port1_dns1
  port1_dns2    = var.port1_dns2

  # Port 2 configuration
  port2_type    = var.port2_type
  port2_ip      = var.port2_ip
  port2_subnet  = var.port2_subnet
  port2_gateway = var.port2_gateway
  port2_dns1    = var.port2_dns1
  port2_dns2    = var.port2_dns2

  # Licensing
  license_key    = var.license_key
  license_secret = var.license_secret

  # Advanced configuration
  host1_name = var.host1_name
  host1_ip   = var.host1_ip
  host2_name = var.host2_name
  host2_ip   = var.host2_ip
  host3_name = var.host3_name
  host3_ip   = var.host3_ip

  # Tags and metadata
  tags               = var.tags
  custom_attributes  = var.custom_attributes
  annotation         = var.annotation
}
