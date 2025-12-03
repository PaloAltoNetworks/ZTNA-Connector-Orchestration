locals {
    data_raw = yamldecode(file("${path.cwd}/../../tf_data_gcp.yaml"))
    provider_data = {
        provider_name = local.data_raw.provider.name
        provider_region = local.data_raw.provider.region
        provider_zone = local.data_raw.provider.zone
        provider_project = local.data_raw.provider.project
        service_account_email = local.data_raw.provider.service_account_email
        service_account_key = local.data_raw.provider.service_account_key
        service_account_scopes = local.data_raw.provider.service_account_scopes
        contact_info = local.data_raw.provider.contact_info
    }
    subnet_data={
        external_vpc = local.data_raw.vpcs.external_name
        external_subnet = local.data_raw.vpcs.external_subnet
        internal_vpc = local.data_raw.vpcs.internal_name
        internal_subnet = local.data_raw.vpcs.internal_subnet
        internal_cidr = local.data_raw.vpcs.internal_cidr
    }
    instance_data={
        name = local.data_raw.instance_details.name
        cloud_image = local.data_raw.instance_details.cloud_image
        machine_type = local.data_raw.instance_details.machine_type
        network_tags = local.data_raw.instance_details.network_tags
    }
}

provider "google" {
    credentials  = file(local.provider_data.service_account_key)
    project      = local.provider_data.provider_project
    region       = local.provider_data.provider_region
    zone         = local.provider_data.provider_zone
}

resource "google_compute_instance" "connector" {
    name           = local.instance_data.name
    machine_type   = local.instance_data.machine_type
    zone           = local.provider_data.provider_zone
    tags           = local.instance_data.network_tags
    can_ip_forward = "true"

    boot_disk {
        initialize_params {
            image = local.instance_data.cloud_image
        }
    }

    network_interface {
        subnetwork = local.subnet_data.external_subnet
    }

    network_interface {
        subnetwork = local.subnet_data.internal_subnet
    }

    service_account {
        email = local.provider_data.service_account_email
        scopes = local.provider_data.service_account_scopes
    }

    metadata  = {
        block-project-ssh-keys = "true"
        serial-port-enable     = "true"
        cloudgenix             = file("${path.cwd}/../metadata_gcp_2_arm.yaml")
    }

    labels = {
        contact_info = local.provider_data.contact_info
        no-shut-contact = local.provider_data.contact_info
    }
}

