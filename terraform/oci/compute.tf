resource "oci_core_instance" "ztna-connector-vm" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.vm_compute_shape

  shape_config {
    baseline_ocpu_utilization = "BASELINE_1_1"
    memory_in_gbs             = "16"
    ocpus                     = "2"
  }

  create_vnic_details {
    subnet_id              = var.internet_subnet_id
    hostname_label         = "${var.vm_display_name}-internet-vnic"
    display_name           = "${var.vm_display_name}-internet-vnic"
    assign_public_ip       = "false"
    assign_ipv6ip          = "false"
  }

  launch_options {
    network_type           = "PARAVIRTUALIZED"
    boot_volume_type       = "PARAVIRTUALIZED"
    firmware               = "BIOS"
  }

  metadata = {
    "user_data" = base64encode(local.metadata)
  }

  platform_config {
    is_symmetric_multi_threading_enabled = "true"
    type                                 = "AMD_VM"
  }

  source_details {
    source_type = "image"
    source_id   = local.compute_image_id
  }

  freeform_tags = {(var.tag_key_name) = (var.tag_value)}
}

resource "oci_core_vnic_attachment" "ztna-connector-dc-vnic" {
  for_each = var.number_of_nics == "2" ? toset(["secondary_nic"]) : toset([])

  instance_id = oci_core_instance.ztna-connector-vm.id

  create_vnic_details {
    subnet_id         = var.data_center_subnet_id
    assign_public_ip  = "false"
    assign_ipv6ip     = "false"
    hostname_label    = "${var.vm_display_name}-dc-vnic"
    display_name      = "${var.vm_display_name}-dc-vnic"
  }
  depends_on = [oci_core_instance.ztna-connector-vm]
}

resource "null_resource" "power_off_vm_on_destroy" {
  # This resource depends on the VNIC attachment, ensuring it runs before the attachment is destroyed.
  # This is the correct way to establish the destroy-time dependency.
  depends_on = [oci_core_vnic_attachment.ztna-connector-dc-vnic]

  # Pass the instance ID into the triggers map.
  # This makes the instance ID available to the local-exec provisioner via self.triggers.instance_id
  triggers = {
    instance_id = oci_core_instance.ztna-connector-vm.id
  }

  provisioner "local-exec" {
    # Now, reference the instance ID using self.triggers.instance_id
    command = "oci compute instance terminate --instance-id ${self.triggers.instance_id} --force --wait-for-state TERMINATED"

    # This ensures the provisioner runs ONLY when the null_resource is being destroyed.
    when = destroy
  }
}
