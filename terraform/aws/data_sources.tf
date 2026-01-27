# Data source for current AWS region
data "aws_region" "current" {}

# Data source for VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Data source for public subnet
data "aws_subnet" "public" {
  id = var.public_subnet_id
}

# Data source for private subnet (for 2-NIC deployments)
data "aws_subnet" "private" {
  count = var.number_of_nics == "2" ? 1 : 0
  id    = var.private_subnet_id
}
