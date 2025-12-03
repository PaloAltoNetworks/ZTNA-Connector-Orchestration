locals {
    data_raw = yamldecode(file("${path.cwd}/../../tf_data_oci.yaml"))

    provider_data = {
        tenancy_ocid = local.data_raw.provider.tenancy_ocid
        user_ocid = local.data_raw.provider.user_ocid
        fingerprint = local.data_raw.provider.fingerprint
        region = local.data_raw.provider.region
        private_key_path = local.data_raw.provider.private_key_path
    }

    compartment_data = {
        compartment_id = local.data_raw.compartment.compartment_id
        availability_domain = local.data_raw.compartment.availability_domain
    }
    subnet_data = {
        subnet_id = local.data_raw.vcn.external_subnet
        public_ip = local.data_raw.vcn.public_ip
    }
    instance_data = {
        name = local.data_raw.instance_details.name
        shape = local.data_raw.instance_details.shape
        image_id = local.data_raw.instance_details.image_id
        memory_in_gbs = local.data_raw.instance_details.memory_in_gbs
        ocpus = local.data_raw.instance_details.ocpus
    }
    
}

data "template_file" "cloud-config" {
    template = file("${path.cwd}/../metadata_oci_1_arm.yaml")
}

provider "oci" {
    tenancy_ocid = local.provider_data.tenancy_ocid
    user_ocid = local.provider_data.user_ocid
    fingerprint = local.provider_data.fingerprint
    region = local.provider_data.region
    private_key_path = local.provider_data.private_key_path
}

resource "oci_core_instance" "pa_connector" {
    availability_domain = local.compartment_data.availability_domain
    compartment_id = local.compartment_data.compartment_id
    shape = local.instance_data.shape
    display_name = local.instance_data.name

    source_details {
        source_type = "image"
        source_id = local.instance_data.image_id
    }

    shape_config {
        memory_in_gbs = local.instance_data.memory_in_gbs
        ocpus         = local.instance_data.ocpus
    }
    create_vnic_details {
        subnet_id = local.subnet_data.subnet_id
        assign_public_ip = local.subnet_data.public_ip
    }

    metadata = {
        user_data = "${base64encode(data.template_file.cloud-config.rendered)}"
    }
}
