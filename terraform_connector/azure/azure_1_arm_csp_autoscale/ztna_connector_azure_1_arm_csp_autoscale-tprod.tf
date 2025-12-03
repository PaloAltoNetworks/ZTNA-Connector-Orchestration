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
    meta_data_raw = yamldecode(file("${path.cwd}/../metadata_azure_1_arm_csp_autoscale.yaml"))
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
        external_subnet = local.data_raw.vnet.external_subnet
        vnet_addr_prefix = local.data_raw.vnet.vnet_addr_prefix
        external_cidr = local.data_raw.vnet.external_cidr
    }
    instance_data={
        name = local.data_raw.instance_details.name
        location = local.data_raw.instance_details.location
        rg_name = local.data_raw.instance_details.rg_name
        os_disk_name = local.data_raw.instance_details.os_disk_name
        boot_diag_storage_account_name = local.data_raw.instance_details.boot_diag_storage_account_name
    }
    autoscale_data={
        min_size = local.data_raw.autoscale.min_size
        max_size = local.data_raw.autoscale.max_size
        scalein_bw_mbps = local.data_raw.autoscale.scalein_bw_mbps
        scaleout_bw_mbps = local.data_raw.autoscale.scaleout_bw_mbps
        scaleset_name = local.data_raw.autoscale.scaleset_name
    }
    general_data={
        license_key = local.meta_data_raw.License.key
        license_secret = local.meta_data_raw.License.secret
        host1_ip = local.meta_data_raw.General.host1_ip
    }
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

# Create a resource group
resource "azurerm_resource_group" "ztna_resource_group" {
    name     = local.instance_data.rg_name
    location = local.instance_data.location
    tags = {
        contact_info = local.provider_data.contact_info
    }
}

resource "azurerm_resource_group_template_deployment" "ztna_connector_1arm_autoscale" {
  name                = local.instance_data.name
  resource_group_name = azurerm_resource_group.ztna_resource_group.name
  deployment_mode = "Incremental"
  template_content = file("${path.cwd}/../AZURE-PA-ZTNA-Connector-1ARM-Autoscale-tprod.json")

  parameters_content = jsonencode({
    "virtualNetworkName" = {
      value = local.vnet_data.vnet_name
    }
    "vnetNewOrExisting" = {
      value = "existing"
    }
    "virtualNetworkAddressPrefixes" = {
      value = local.vnet_data.vnet_addr_prefix
    }
    "virtualNetworkExistingRGName" = {
      value = local.vnet_data.rg_name
    }
    "subnet1Name" = {
      value = local.vnet_data.external_subnet
    }
    "subnet1Prefix" = {
      value = local.vnet_data.external_cidr
    }
    "licenseKey" = {
      value = local.general_data.license_key
    }
    "licenseSecret" = {
      value = local.general_data.license_secret
    }
    "scaleSetName" = {
      value = local.autoscale_data.scaleset_name
    }
    "maxInstanceCount" = {
      value = local.autoscale_data.max_size
    }
    "ScaleOutMetricMbps" = {
      value = local.autoscale_data.scaleout_bw_mbps
    }
    "ScaleInMetricMbps" = {
      value = local.autoscale_data.scalein_bw_mbps
    }
    "host1_ip" = {
      value = local.general_data.host1_ip
    }
  })

  timeouts {
    delete = "70m"
  }

  tags = {
    "Name" = local.instance_data.name
    "no-shut-contact" = local.provider_data.contact_info
  }
}