###################################################################################################
# NOTE:
# 1. Please make sure Azure client certificate and key file is present on your controller:
#    File path: /home/test/pa_conn_certs/azr_client.pfx
#    This is required for terraform Azure provider to authenticate via a Service Principal with the client cert
#    More details in https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/
#    service_principal_client_certificate
# 2. Make sure all required prerequisites mentioned in the following confluence page is taken care:
#    https://confluence.paloaltonetworks.local/display/CYR/Base+Config+Requirements+for+ZTNA+Connector+GPCS+tests
###################################################################################################

terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "3.54.0"
        }
    }
}

locals {
    data_raw = yamldecode(file("${path.cwd}/../../tf_data_azure.yaml"))
    provider_data_raw = yamldecode(file("/home/test/pa_conn_certs/tf_provider_data_azure.yaml"))
    provider_data = {
        client_id = local.provider_data_raw.client_id
        client_certificate_path = local.provider_data_raw.client_certificate_path
        client_certificate_password = local.provider_data_raw.client_certificate_password
        tenant_id = local.provider_data_raw.tenant_id
        subscription_id = local.provider_data_raw.subscription_id
        contact_info = local.provider_data_raw.contact_info
    }
    vnet_data={
        vnet_name = local.data_raw.vnet.vnet_name
        rg_name = local.data_raw.vnet.rg_name
        port1_vni_name = local.data_raw.vnet.port1_vni_name
        port2_vni_name = local.data_raw.vnet.port2_vni_name
        port2_static_ip = local.data_raw.vnet.port2_static_ip
        external_subnet = local.data_raw.vnet.external_subnet
        internal_subnet = local.data_raw.vnet.internal_subnet
    }
    instance_data={
        name = local.data_raw.instance_details.name
        image_name = local.data_raw.instance_details.image_name
        vhd_image = local.data_raw.instance_details.vhd_image
        location = local.data_raw.instance_details.location
        rg_name = local.data_raw.instance_details.rg_name
        os_disk_name = local.data_raw.instance_details.os_disk_name
        boot_diag_storage_account_name = local.data_raw.instance_details.boot_diag_storage_account_name
    }

    # Read the base metadata template
    base_metadata = yamldecode(file("${path.cwd}/../metadata_azure_2_arm.yaml"))

    # Calculate gateway address (first usable IP in the LAN subnet)
    lan_subnet_cidr = data.azurerm_subnet.ztna-connector-vnet-lan.address_prefixes[0]
    gateway_ip = cidrhost(local.lan_subnet_cidr, 1)

    # Create updated metadata with port2 IP address
    updated_metadata = yamlencode({
        General = local.base_metadata.General
        License = local.base_metadata.License
        "1" = local.base_metadata["1"]
        "2" = merge(local.base_metadata["2"], {
            address = "${azurerm_network_interface.ztna_conn_port2_vni.private_ip_address}/24"
            gateway = local.gateway_ip
        })
    })
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id                   = local.provider_data.client_id
  client_certificate_path     = local.provider_data.client_certificate_path
  client_certificate_password = local.provider_data.client_certificate_password
  tenant_id                   = local.provider_data.tenant_id
  subscription_id             = local.provider_data.subscription_id
}

# Refer to existing ztna-connector-qa RG -> ztna-connector-vnet vnet -> wan subnet
data "azurerm_subnet" "ztna-connector-vnet-wan" {
    name                 = local.vnet_data.external_subnet
    virtual_network_name = local.vnet_data.vnet_name
    resource_group_name  = local.vnet_data.rg_name
}

# Refer to existing ztna-connector-qa RG -> ztna-connector-vnet vnet -> lan subnet
data "azurerm_subnet" "ztna-connector-vnet-lan" {
    name                 = local.vnet_data.internal_subnet
    virtual_network_name = local.vnet_data.vnet_name
    resource_group_name  = local.vnet_data.rg_name
}

# Create a resource group
resource "azurerm_resource_group" "ztna_resource_group" {
    name     = local.instance_data.rg_name
    location = local.instance_data.location
    tags = {
        contact_info = local.provider_data.contact_info
    }
}

# Azure Storage Account for Boot Diagnostics
resource "azurerm_storage_account" "ztnatwoarmstorageaccount" {
  name                          = local.instance_data.boot_diag_storage_account_name
  resource_group_name           = azurerm_resource_group.ztna_resource_group.name
  location                      = azurerm_resource_group.ztna_resource_group.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  depends_on                    = [azurerm_resource_group.ztna_resource_group]
# Azure Storage Account Network rules to be compliant with policy assigned to PRISMAACCESS-NONPROD management group
  public_network_access_enabled = true
  network_rules {
    default_action              = "Deny"
    # QA testbed controller - 8.47.64.2
    # Globalprotect pangp Internal GW - 199.167.54.229
    # Globalprotect / PA Agent pangp california-gw - 199.167.52.5
    # PA Agent pangp US Northwest - 54.215.48.190
    # PA Agent pangp US Northwest - 13.52.128.115
    ip_rules                    = ["8.47.64.2", "199.167.54.229", "199.167.52.5", "54.215.48.190", "13.52.128.115"]
    bypass                     = ["AzureServices"]
  }
}

# Virtual Network Adapter for port1 (WAN port)
resource "azurerm_network_interface" "ztna_conn_port1_vni" {
    name                = local.vnet_data.port1_vni_name
    location            = azurerm_resource_group.ztna_resource_group.location
    resource_group_name = azurerm_resource_group.ztna_resource_group.name
    depends_on          = [azurerm_resource_group.ztna_resource_group]
    ip_configuration {
        name                          = "ztna_conn_port1_ipconfig"
        subnet_id                     = "${data.azurerm_subnet.ztna-connector-vnet-wan.id}"
        private_ip_address_allocation = "Dynamic"
    }
}

# Virtual Network Adapter for port2 (LAN port)
resource "azurerm_network_interface" "ztna_conn_port2_vni" {
    name                = local.vnet_data.port2_vni_name
    location            = azurerm_resource_group.ztna_resource_group.location
    resource_group_name = azurerm_resource_group.ztna_resource_group.name
    depends_on          = [azurerm_resource_group.ztna_resource_group]
    ip_configuration {
        name                          = "ztna_conn_port2_ipconfig"
        subnet_id                     = "${data.azurerm_subnet.ztna-connector-vnet-lan.id}"
        private_ip_address_allocation = "Dynamic"
#        private_ip_address_allocation = "Static"
#        private_ip_address            = local.vnet_data.port2_static_ip
    }
}

# Azure Image from VHD
resource "azurerm_image" "ztna_conn_image" {
    name                  = local.instance_data.image_name
    resource_group_name   = azurerm_resource_group.ztna_resource_group.name
    location              = azurerm_resource_group.ztna_resource_group.location

    os_disk {
        os_type  = "Linux"
        os_state = "Generalized"
        blob_uri = local.instance_data.vhd_image
        size_gb  = 40
    }
}

# Virtual machine
resource "azurerm_virtual_machine" "ztna_conn_vm" {
    name                  = local.instance_data.name
    resource_group_name   = azurerm_resource_group.ztna_resource_group.name
    location              = azurerm_resource_group.ztna_resource_group.location
    vm_size               = "Standard_D4s_v3"
    network_interface_ids = [azurerm_network_interface.ztna_conn_port1_vni.id,
                             azurerm_network_interface.ztna_conn_port2_vni.id]
    primary_network_interface_id = azurerm_network_interface.ztna_conn_port1_vni.id
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    depends_on            = [azurerm_network_interface.ztna_conn_port1_vni,
                             azurerm_network_interface.ztna_conn_port2_vni]

    storage_os_disk {
        name              = local.instance_data.os_disk_name
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    storage_image_reference {
        id                = azurerm_image.ztna_conn_image.id
    }
    os_profile {
        computer_name  = local.instance_data.name
        admin_username = "elem-admin"
        admin_password = "RandomPassword1"
        custom_data   =  local.updated_metadata
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    boot_diagnostics {
        enabled = true
        storage_uri = azurerm_storage_account.ztnatwoarmstorageaccount.primary_blob_endpoint
    }
    tags = {
        contact_info = local.provider_data.contact_info
        no-shut-contact = local.provider_data.contact_info
    }
}
