locals {
  data_raw = yamldecode(file("${path.cwd}/../../tf_data_aws.yaml"))
  provider_data = {
      provider_name = local.data_raw.provider.name
      provider_region = local.data_raw.provider.region
      provider_access_key = local.data_raw.provider.access_key
      provider_secret_key = local.data_raw.provider.secret_key
  }
  subnet_data={
      vpc = local.data_raw.vpc.vpc_id
      external_subnet = local.data_raw.vpc.external
      internal_subnet = local.data_raw.vpc.internal
      sg = local.data_raw.vpc.sg
  }
  instance_data={
      name = local.data_raw.vpc.instance_details.name
      ami = local.data_raw.vpc.instance_details.ami
      instance_type = local.data_raw.vpc.instance_details.instance_type
      ip_allocation = local.data_raw.vpc.instance_details.ip_allocation
  }  
}

provider "aws" {
  access_key = local.provider_data.provider_access_key
  secret_key = local.provider_data.provider_secret_key
  region     = local.provider_data.provider_region
}

resource "aws_network_interface" "nic1" {
  subnet_id       = local.subnet_data.external_subnet
}

resource "aws_network_interface" "nic2" {
  subnet_id       = local.subnet_data.internal_subnet
}

resource "aws_instance" "connector" {
  ami           = local.instance_data.ami
  instance_type = local.instance_data.instance_type

  root_block_device {
      volume_size           = "40"
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
  }

  user_data = file("${path.cwd}/../metadata_aws_2_arm.yaml")

  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.nic1.id
  }
        
  network_interface {
      device_index = 1
      network_interface_id = aws_network_interface.nic2.id
  }

  tags = {
    "Name" = local.instance_data.name
    "no-shut-contact" = "dpandit@paloaltonetworks.com"
  }

}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = local.subnet_data.sg
  network_interface_id = aws_network_interface.nic1.id
}

# resource "aws_eip_association" "eip_assoc" {
#   allocation_id = local.instance_data.ip_allocation
#   network_interface_id = aws_network_interface.nic1.id
# }
