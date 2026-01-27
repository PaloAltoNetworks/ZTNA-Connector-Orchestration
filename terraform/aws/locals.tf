locals {
  # Use provided region or default to current AWS region
  region = var.region != "" ? var.region : data.aws_region.current.name

  # AMI selection - custom AMI or regional mapping
  ami_id = var.use_custom_ami ? var.custom_ami_id : lookup(var.regional_ami_map, local.region, "")

  # IP address allocation method
  use_static_public_ip  = var.public_nic_private_ip != "0.0.0.0"
  use_static_private_ip = var.private_nic_private_ip != "0.0.0.0"

  # Security group ID - use existing or reference the created one
  security_group_id = var.create_security_group ? aws_security_group.ztna_sg[0].id : var.security_group_id

  # User data / cloud-init configuration
  # Format matches the CloudFormation templates
  user_data_1_nic = templatefile("${path.module}/templates/user-data-1-nic.tpl", {
    license_key    = var.vm_license_key
    license_secret = var.vm_license_secret
  })

  user_data_2_nic = templatefile("${path.module}/templates/user-data-2-nic.tpl", {
    license_key    = var.vm_license_key
    license_secret = var.vm_license_secret
  })

  user_data = var.enable_bootstrap ? (var.number_of_nics == "2" ? local.user_data_2_nic : local.user_data_1_nic) : null

  # Network interface configurations
  network_interface_ids = var.number_of_nics == "2" ? [
    aws_network_interface.public_nic.id,
    aws_network_interface.private_nic[0].id
  ] : [aws_network_interface.public_nic.id]

  # Tags with instance name
  instance_tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
}
