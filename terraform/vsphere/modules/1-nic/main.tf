# Deploy ZTNA Connector from OVA/OVF
resource "vsphere_virtual_machine" "ztna_connector" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder

  num_cpus               = var.num_cpus
  num_cores_per_socket   = var.num_cores_per_socket
  memory                 = var.memory_mb
  guest_id               = var.guest_id
  firmware               = var.firmware
  annotation             = var.annotation
  enable_disk_uuid       = true
  wait_for_guest_net_timeout = 0

  # Network interface for Port1 (PublicWAN)
  network_interface {
    network_id   = data.vsphere_network.port1.id
    adapter_type = var.port1_adapter_type
  }

  # Deploy from OVF/OVA
  ovf_deploy {
    local_ovf_path        = var.ovf_local_path != "" ? var.ovf_local_path : null
    remote_ovf_url        = var.ovf_remote_url != "" ? var.ovf_remote_url : null
    disk_provisioning     = var.disk_thin_provisioned ? "thin" : "thick"
    allow_unverified_ssl_cert = var.allow_unverified_ssl

    # Map OVF network to vSphere network
    ovf_network_map = {
      "Port1" = data.vsphere_network.port1.id
    }
  }

  # OVF vApp properties for configuration
  vapp {
    properties = {
      # Licensing
      "key"    = var.license_key
      "secret" = var.license_secret

      # Model type
      "type" = "ion 200v"

      # Port 1 configuration
      "port1role"    = "PublicWAN"
      "port1type"    = var.port1_type
      "port1ip"      = var.port1_ip
      "port1subnet"  = var.port1_subnet
      "port1gateway" = var.port1_gateway
      "port1dns1"    = var.port1_dns1
      "port1dns2"    = var.port1_dns2
      "port1name"    = "1"

      # Static host entries (advanced configuration)
      "host1name" = var.host1_name
      "host1ip"   = var.host1_ip
      "host2name" = var.host2_name
      "host2ip"   = var.host2_ip
      "host3name" = var.host3_name
      "host3ip"   = var.host3_ip
    }
  }

  # Disk configuration
  disk {
    label            = "disk0"
    size             = var.disk_size_gb
    thin_provisioned = var.disk_thin_provisioned
  }

  # Tags
  tags = var.tags

  # Custom attributes
  dynamic "custom_attributes" {
    for_each = var.custom_attributes
    content {
      key   = custom_attributes.key
      value = custom_attributes.value
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to vApp properties after initial deployment
      # to prevent unnecessary updates
      vapp[0].properties
    ]
  }
}
