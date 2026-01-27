###
# EC2 Instance Outputs
###

output "instance_id" {
  description = "The ID of the ZTNA Connector EC2 instance"
  value       = aws_instance.ztna_connector.id
}

output "instance_arn" {
  description = "The ARN of the ZTNA Connector EC2 instance"
  value       = aws_instance.ztna_connector.arn
}

output "instance_state" {
  description = "The state of the ZTNA Connector EC2 instance"
  value       = aws_instance.ztna_connector.instance_state
}

output "instance_type" {
  description = "The instance type of the ZTNA Connector"
  value       = aws_instance.ztna_connector.instance_type
}

output "availability_zone" {
  description = "The availability zone of the ZTNA Connector"
  value       = aws_instance.ztna_connector.availability_zone
}

###
# Network Interface Outputs
###

output "public_nic_id" {
  description = "The ID of the public/internet network interface (NIC1)"
  value       = aws_network_interface.public_nic.id
}

output "public_nic_private_ip" {
  description = "The private IP address of the public/internet NIC"
  value       = aws_network_interface.public_nic.private_ip
}

output "private_nic_id" {
  description = "The ID of the private/LAN network interface (NIC2) - only for 2-NIC deployments"
  value       = var.number_of_nics == "2" ? aws_network_interface.private_nic[0].id : null
}

output "private_nic_private_ip" {
  description = "The private IP address of the private/LAN NIC - only for 2-NIC deployments"
  value       = var.number_of_nics == "2" ? aws_network_interface.private_nic[0].private_ip : null
}

###
# Security Group Outputs
###

output "security_group_id" {
  description = "The ID of the security group"
  value       = local.security_group_id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = var.create_security_group ? aws_security_group.ztna_sg[0].name : var.security_group_name
}

###
# VPC and Subnet Outputs
###

output "vpc_id" {
  description = "The VPC ID where the ZTNA Connector is deployed"
  value       = var.vpc_id
}

output "public_subnet_id" {
  description = "The subnet ID for the public/internet interface"
  value       = var.public_subnet_id
}

output "private_subnet_id" {
  description = "The subnet ID for the private/LAN interface - only for 2-NIC deployments"
  value       = var.number_of_nics == "2" ? var.private_subnet_id : null
}

###
# Additional Information
###

output "ami_id" {
  description = "The AMI ID used for the ZTNA Connector"
  value       = local.ami_id
}

output "region" {
  description = "The AWS region where the ZTNA Connector is deployed"
  value       = local.region
}

output "number_of_nics" {
  description = "The number of network interfaces configured (1 or 2)"
  value       = var.number_of_nics
}
