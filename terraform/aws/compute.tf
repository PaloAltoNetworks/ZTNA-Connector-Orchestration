# Security Group for ZTNA Connector
resource "aws_security_group" "ztna_sg" {
  count       = var.create_security_group ? 1 : 0
  name        = var.security_group_name
  description = "ZTNA Connector Allow Egress Security Group"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = var.security_group_name })

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Optional ingress rules (if specified)
  dynamic "ingress" {
    for_each = length(var.allowed_ingress_cidrs) > 0 ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.allowed_ingress_cidrs
      description = "Allow ingress from specified CIDRs"
    }
  }
}

# Network Interface for Public/Internet (NIC1)
# For 1-NIC: This is the single interface
# For 2-NIC: This is the PublicWAN interface
resource "aws_network_interface" "public_nic" {
  subnet_id         = var.public_subnet_id
  private_ips       = local.use_static_public_ip ? [var.public_nic_private_ip] : null
  security_groups   = [local.security_group_id]
  source_dest_check = var.number_of_nics == "1" ? false : true
  description       = var.number_of_nics == "1" ? "Interface for single port" : "Interface for PublicWAN"

  tags = merge(var.tags, {
    Name    = "${var.instance_name}-eth0"
    Network = var.number_of_nics == "1" ? "DCLan" : "VPN"
  })

  depends_on = [aws_security_group.ztna_sg]
}

# Network Interface for Private/LAN (NIC2) - only for 2-NIC deployments
resource "aws_network_interface" "private_nic" {
  count             = var.number_of_nics == "2" ? 1 : 0
  subnet_id         = var.private_subnet_id
  private_ips       = local.use_static_private_ip ? [var.private_nic_private_ip] : null
  security_groups   = [local.security_group_id]
  source_dest_check = false
  description       = "Interface for Data Center LAN"

  tags = merge(var.tags, {
    Name    = "${var.instance_name}-eth1"
    Network = "DCLan"
  })

  depends_on = [aws_security_group.ztna_sg]
}

# EC2 Instance for ZTNA Connector
resource "aws_instance" "ztna_connector" {
  ami               = local.ami_id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone != "" ? var.availability_zone : null
  key_name          = var.key_name != "" ? var.key_name : null
  user_data         = local.user_data

  # Network interfaces are attached separately
  # We cannot use vpc_security_group_ids when using network_interface
  dynamic "network_interface" {
    for_each = var.number_of_nics == "2" ? [
      { index = 0, id = aws_network_interface.public_nic.id },
      { index = 1, id = aws_network_interface.private_nic[0].id }
    ] : [{ index = 0, id = aws_network_interface.public_nic.id }]

    content {
      device_index         = network_interface.value.index
      network_interface_id = network_interface.value.id
    }
  }

  # Root volume configuration
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.root_volume_delete_on_termination
    tags = merge(var.tags, {
      Name = "${var.instance_name}-root-volume"
    })
  }

  tags = local.instance_tags

  depends_on = [
    aws_network_interface.public_nic,
    aws_network_interface.private_nic
  ]

  lifecycle {
    ignore_changes = [
      # Ignore changes to user_data after initial creation
      # to prevent unnecessary instance replacements
      user_data
    ]
  }
}
