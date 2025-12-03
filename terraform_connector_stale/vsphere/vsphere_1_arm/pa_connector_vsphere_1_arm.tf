locals {
  data_raw = yamldecode(file("${path.cwd}/../../tf_data_vsphere.yaml"))
  vsphere_data = {
    server = local.data_raw.vsphere.server
    vsphere_user = local.data_raw.vsphere.user
    vsphere_password = local.data_raw.vsphere.password
    datacenter = local.data_raw.vsphere.datacenter
    datastore = local.data_raw.vsphere.datastore
    resource_pool = local.data_raw.vsphere.resource_pool
    network = local.data_raw.vsphere.network
    ova_path = local.data_raw.vsphere.ova_path
  }
  connector_data = {
    name = local.data_raw.connector.name
    esxi_host = local.data_raw.connector.esxi_host
    token = local.data_raw.connector.token
    secret = local.data_raw.connector.secret
    port1_ip = local.data_raw.connector.port1_ip
    port1_subnet = local.data_raw.connector.port1_subnet
    port1_gateway = local.data_raw.connector.port1_gateway
    port1_dns1 = local.data_raw.connector.port1_dns1
    port1_dns2 = local.data_raw.connector.port1_dns2
    host1_name = local.data_raw.connector.host1_name
    host1_ip = local.data_raw.connector.host1_ip
    host2_name = local.data_raw.connector.host2_name
    host2_ip = local.data_raw.connector.host2_ip
    host3_name = local.data_raw.connector.host3_name
    host3_ip = local.data_raw.connector.host3_ip
  }
}

provider "vsphere" {
  vsphere_server = local.vsphere_data.server
  user           = local.vsphere_data.vsphere_user
  password       = local.vsphere_data.vsphere_password
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = local.vsphere_data.datacenter
}

data "vsphere_host" "host" {
  name          = local.connector_data.esxi_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = local.vsphere_data.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = local.vsphere_data.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = local.vsphere_data.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "connector" {
  name             = local.connector_data.name
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0

  num_cpus = 4
  memory   = 8192
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  ovf_deploy {
    local_ovf_path = local.vsphere_data.ova_path
    disk_provisioning = "thin"
    ovf_network_map = {
      "VM Network" = data.vsphere_network.network.id
    }
  }

  vapp {
    properties = {
      "key" = local.connector_data.token
      "secret" = local.connector_data.secret
      "port1ip" = local.connector_data.port1_ip
      "port1subnet" = local.connector_data.port1_subnet
      "port1gateway" = local.connector_data.port1_gateway
      "port1role" = "PublicWAN"
      "port1type" = "Static"
      "port1dns1" = local.connector_data.port1_dns1
      "port1dns2" = local.connector_data.port1_dns2
      "host1name" = local.connector_data.host1_name
      "host1ip" = local.connector_data.host1_ip
      "host2name" = local.connector_data.host2_name
      "host2ip" = local.connector_data.host2_ip
      "host3name" = local.connector_data.host3_name
      "host3ip" = local.connector_data.host3_ip
    }
  }
}
