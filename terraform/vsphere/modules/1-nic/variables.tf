############################
#  vSphere Infrastructure  #
############################
variable "vsphere_server" {
  description = "vSphere server (vCenter or ESXi) - can be set via VSPHERE_SERVER env var"
  type        = string
  default     = ""
}

variable "datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "cluster" {
  description = "vSphere cluster name (optional if using resource_pool)"
  type        = string
  default     = ""
}

variable "resource_pool" {
  description = "vSphere resource pool name (optional)"
  type        = string
  default     = ""
}

variable "datastore" {
  description = "vSphere datastore name for VM storage"
  type        = string
}

variable "folder" {
  description = "vSphere folder path for the VM (optional)"
  type        = string
  default     = ""
}

############################
#  OVA/OVF Configuration   #
############################
variable "ovf_local_path" {
  description = "Local path to the 1-NIC OVA file"
  type        = string
}

variable "ovf_remote_url" {
  description = "Remote URL to the 1-NIC OVA file (alternative to local_path)"
  type        = string
  default     = ""
}

variable "allow_unverified_ssl" {
  description = "Allow unverified SSL certificates for OVF deployment"
  type        = bool
  default     = false
}

############################
#  VM Configuration        #
############################
variable "vm_name" {
  description = "Name of the ZTNA Connector virtual machine"
  type        = string
  default     = "ztna-connector-1nic"
}

variable "num_cpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 4
}

variable "num_cores_per_socket" {
  description = "Number of cores per CPU socket"
  type        = number
  default     = 4
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 8192
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 40
}

variable "disk_thin_provisioned" {
  description = "Use thin provisioning for disk"
  type        = bool
  default     = true
}

variable "guest_id" {
  description = "Guest OS identifier"
  type        = string
  default     = "ubuntu64Guest"
}

variable "firmware" {
  description = "Firmware type (bios or efi)"
  type        = string
  default     = "bios"
}

############################
#  Network Configuration   #
############################
variable "port1_network" {
  description = "Port group/network name for Port1 (PublicWAN)"
  type        = string
}

variable "port1_adapter_type" {
  description = "Network adapter type for Port1"
  type        = string
  default     = "vmxnet3"
}

############################
#  Port 1 OVF Properties   #
############################
variable "port1_type" {
  description = "Port1 configuration type (DHCP or Static)"
  type        = string
  default     = "DHCP"
  validation {
    condition     = contains(["DHCP", "Static"], var.port1_type)
    error_message = "The port1_type must be either 'DHCP' or 'Static'."
  }
}

variable "port1_ip" {
  description = "Port1 static IP address (0.0.0.0 for DHCP)"
  type        = string
  default     = "0.0.0.0"
}

variable "port1_subnet" {
  description = "Port1 subnet mask in CIDR format (e.g., 24 for /24)"
  type        = number
  default     = 0
  validation {
    condition     = var.port1_subnet >= 0 && var.port1_subnet <= 32
    error_message = "The port1_subnet must be between 0 and 32."
  }
}

variable "port1_gateway" {
  description = "Port1 gateway IP address (0.0.0.0 for none)"
  type        = string
  default     = "0.0.0.0"
}

variable "port1_dns1" {
  description = "Port1 primary DNS server (0.0.0.0 for none)"
  type        = string
  default     = "0.0.0.0"
}

variable "port1_dns2" {
  description = "Port1 secondary DNS server (0.0.0.0 for none)"
  type        = string
  default     = "0.0.0.0"
}

############################
#  ZTNA License Configuration #
############################
variable "license_key" {
  description = "ZTNA Connector license key"
  type        = string
  sensitive   = true
}

variable "license_secret" {
  description = "ZTNA Connector license secret"
  type        = string
  sensitive   = true
}

############################
#  Advanced Configuration  #
############################
variable "host1_name" {
  description = "Static host entry 1 name"
  type        = string
  default     = "controller.cgnx.net"
}

variable "host1_ip" {
  description = "Static host entry 1 IP (0.0.0.0 for none)"
  type        = string
  default     = "0.0.0.0"
}

variable "host2_name" {
  description = "Static host entry 2 name"
  type        = string
  default     = "vmfg.cgnx.net"
}

variable "host2_ip" {
  description = "Static host entry 2 IP (0.0.0.0 for none)"
  type        = string
  default     = "0.0.0.0"
}

variable "host3_name" {
  description = "Static host entry 3 name"
  type        = string
  default     = "locator.cgnx.net"
}

variable "host3_ip" {
  description = "Static host entry 3 IP (0.0.0.0 for none)"
  type        = string
  default     = "0.0.0.0"
}

############################
#  Tags and Metadata       #
############################
variable "tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = ["ztna-connector", "1-nic"]
}

variable "custom_attributes" {
  description = "Custom attributes for the VM"
  type        = map(string)
  default     = {}
}

variable "annotation" {
  description = "VM annotation/notes"
  type        = string
  default     = "ZTNA Connector ION 200v - 1 NIC deployment"
}
