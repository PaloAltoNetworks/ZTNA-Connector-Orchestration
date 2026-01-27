############################
#  Hidden Variable Group   #
############################
variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = ""
}

############################
#  AMI Configuration       #
############################
variable "use_custom_ami" {
  description = "Use custom AMI instead of regional AMI mapping"
  type        = bool
  default     = false
}

variable "custom_ami_id" {
  description = "Custom AMI ID (if use_custom_ami is true)"
  type        = string
  default     = ""
}

# Regional AMI mapping - update these with actual AMI IDs for each region
variable "regional_ami_map" {
  description = "Map of AWS regions to ZTNA Connector AMI IDs"
  type        = map(string)
  default = {
    us-east-1      = "ami-0ec34647f50fc20e8"
    us-east-2      = "ami-xxxxxxxxxxxxxxxxx"
    us-west-1      = "ami-xxxxxxxxxxxxxxxxx"
    us-west-2      = "ami-xxxxxxxxxxxxxxxxx"
    ca-central-1   = "ami-xxxxxxxxxxxxxxxxx"
    sa-east-1      = "ami-xxxxxxxxxxxxxxxxx"
    eu-central-1   = "ami-xxxxxxxxxxxxxxxxx"
    eu-west-1      = "ami-xxxxxxxxxxxxxxxxx"
    eu-west-2      = "ami-xxxxxxxxxxxxxxxxx"
    ap-south-1     = "ami-xxxxxxxxxxxxxxxxx"
    ap-northeast-1 = "ami-xxxxxxxxxxxxxxxxx"
    ap-northeast-2 = "ami-xxxxxxxxxxxxxxxxx"
    ap-southeast-1 = "ami-xxxxxxxxxxxxxxxxx"
    ap-southeast-2 = "ami-xxxxxxxxxxxxxxxxx"
  }
}

############################
#  Compute Configuration   #
############################
variable "instance_name" {
  description = "EC2 Instance Name for ZTNA Connector"
  type        = string
  default     = "ztna-connector-vm"
}

variable "instance_type" {
  description = "EC2 instance type for ZTNA Connector (ION 200v)"
  type        = string
  default     = "m5.xlarge"
}

variable "availability_zone" {
  description = "AWS availability zone (e.g., us-east-1a, us-east-1b, or empty for no preference)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (optional)"
  type        = string
  default     = ""
}

############################
#  Network Configuration   #
############################
variable "vpc_id" {
  description = "VPC ID where ZTNA Connector will be deployed"
  type        = string
}

variable "number_of_nics" {
  description = "The number of network interfaces (1 or 2)"
  type        = string
  default     = "1"
  validation {
    condition     = contains(["1", "2"], var.number_of_nics)
    error_message = "The number_of_nics variable must be either '1' or '2'."
  }
}

# For 1-NIC deployments, this is the single subnet
# For 2-NIC deployments, this is the public/internet subnet
variable "public_subnet_id" {
  description = "Subnet ID for the Public/Internet interface (NIC1)"
  type        = string
}

# Only used for 2-NIC deployments
variable "private_subnet_id" {
  description = "Subnet ID for the Private/LAN interface (NIC2) - only for 2-NIC deployments"
  type        = string
  default     = ""
}

# IP address configuration
variable "public_nic_private_ip" {
  description = "Static private IP for public NIC (0.0.0.0 for DHCP)"
  type        = string
  default     = "0.0.0.0"
  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.public_nic_private_ip))
    error_message = "The public_nic_private_ip must be a valid IPv4 address."
  }
}

variable "private_nic_private_ip" {
  description = "Static private IP for private NIC (0.0.0.0 for DHCP) - only for 2-NIC deployments"
  type        = string
  default     = "0.0.0.0"
  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.private_nic_private_ip))
    error_message = "The private_nic_private_ip must be a valid IPv4 address."
  }
}

############################
# Security Group Config    #
############################
variable "create_security_group" {
  description = "Create a new security group for ZTNA Connector"
  type        = bool
  default     = true
}

variable "security_group_id" {
  description = "Existing security group ID (if create_security_group is false)"
  type        = string
  default     = ""
}

variable "security_group_name" {
  description = "Name for the security group (if creating new)"
  type        = string
  default     = "ztna-connector-sg"
}

variable "allowed_ingress_cidrs" {
  description = "List of CIDR blocks allowed for ingress (empty list allows none)"
  type        = list(string)
  default     = []
}

############################
# Additional Configuration #
############################
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "paloaltonetworks-ztna" = "ztna-connector-template"
  }
}

variable "enable_bootstrap" {
  description = "Enable bootstrap configuration via user data"
  type        = bool
  default     = true
}

############################
# ZTNA License Configuration #
############################
variable "vm_license_key" {
  description = "ZTNA Connector license key"
  type        = string
  sensitive   = true
}

variable "vm_license_secret" {
  description = "ZTNA Connector license secret"
  type        = string
  sensitive   = true
}

############################
# EBS Configuration        #
############################
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Type of the root EBS volume (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_delete_on_termination" {
  description = "Delete root volume on instance termination"
  type        = bool
  default     = true
}
