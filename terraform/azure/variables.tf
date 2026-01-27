############################
#  Hidden Variable Group   #
############################
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Name of the resource group where resources will be created"
  type        = string
}

###############################################################################
#  Marketplace Image - Palo Alto Networks ZTNA Connector                     #
###############################################################################
variable "use_marketplace_image" {
  description = "Use Azure Marketplace image?"
  type        = bool
  default     = true
}

variable "marketplace_publisher" {
  description = "Marketplace image publisher"
  type        = string
  default     = "paloaltonetworks"
}

variable "marketplace_offer" {
  description = "Marketplace image offer"
  type        = string
  default     = "pan-prisma-access-ztna-connector"
}

variable "marketplace_sku" {
  description = "Marketplace image SKU"
  type        = string
  default     = "pan-prisma-access-ztna-connector"
}

variable "marketplace_version" {
  description = "Marketplace image version"
  type        = string
  default     = "latest"
}

############################
#  Custom Image           #
############################
variable "custom_image_id" {
  description = "Custom Image resource ID (used if use_marketplace_image is false)"
  type        = string
  default     = ""
}

############################
#  Compute Configuration   #
############################
variable "vm_name" {
  description = "Virtual Machine Name"
  type        = string
  default     = "ztna-connector-vm"
}

variable "vm_size" {
  description = "Azure VM size for ZTNA Connector"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "availability_zone" {
  description = "Azure availability zone (1, 2, 3, or None for no zone)"
  type        = string
  default     = "None"
}

variable "availability_set_name" {
  description = "Name of availability set (None to skip availability set)"
  type        = string
  default     = "None"
}

variable "availability_set_platform_fault_domain_count" {
  description = "Fault domain count for availability set"
  type        = number
  default     = 2
}

variable "availability_set_platform_update_domain_count" {
  description = "Update domain count for availability set"
  type        = number
  default     = 5
}

############################
#  Network Configuration   #
############################
variable "virtual_network_name" {
  description = "Name of the Virtual Network (VNet)"
  type        = string
}

variable "vnet_new_or_existing" {
  description = "Create new VNet or use existing (new/existing)"
  type        = string
  default     = "existing"
  validation {
    condition     = contains(["new", "existing"], var.vnet_new_or_existing)
    error_message = "The vnet_new_or_existing variable must be either 'new' or 'existing'."
  }
}

variable "virtual_network_address_prefixes" {
  description = "Virtual network address CIDR prefixes"
  type        = list(string)
  default     = ["10.5.0.0/16"]
}

variable "virtual_network_existing_rg_name" {
  description = "Resource group name of existing VNet (if applicable)"
  type        = string
  default     = ""
}

variable "subnet1_name" {
  description = "Name of the Internet/Public subnet"
  type        = string
  default     = "Internet"
}

variable "subnet1_prefix" {
  description = "Internet/Public subnet CIDR"
  type        = string
  default     = "10.5.1.0/24"
}

variable "subnet2_name" {
  description = "Name of the LAN/Private subnet (for 2-NIC deployments)"
  type        = string
  default     = "LAN"
}

variable "subnet2_prefix" {
  description = "LAN/Private subnet CIDR (for 2-NIC deployments)"
  type        = string
  default     = "10.5.2.0/24"
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

variable "dc_lan_port_private_ip" {
  description = "Static private IP for the data center LAN interface (for 2-NIC deployments). Format: IP/CIDR e.g., 10.5.2.44/24"
  type        = string
  default     = "10.5.2.44/24"
}

variable "dc_lan_port_gateway" {
  description = "Gateway address for the data center LAN interface (for 2-NIC deployments)"
  type        = string
  default     = "10.5.2.1"
}

variable "dc_lan_port_dns" {
  description = "DNS server address for the data center LAN interface (for 2-NIC deployments)"
  type        = string
  default     = "8.8.8.8"
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
  description = "Enable bootstrap configuration"
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
