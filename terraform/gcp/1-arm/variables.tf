
# gcp project Id is required.
variable "project_id" {
  type = string
}

# Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  description = "The name of the deployment and VM instance."
  default     = "my ztna connector deployment"
  type        = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

# ztna connector vm name is required.
variable "vm_name" {
  type = string
}

# ztna connector port 1 subnet is required.
variable "vm_internet_subnet" {
  type = string
}

# ztna connector port 2 subnet is required.
variable "vm_data_center_subnet" {
  type = string
}

# ztna connector license key is required.
variable "vm_license_key" {
  type = string
}

# ztna connector license secret is required.
variable "vm_license_secret" {
  type = string
}

variable "vm_machine_type" {
  type    = string
  default = "n2-standard-4"
}

variable "image" {
  type    = string
  default = "projects/paloaltonetworksgcp-public/global/images/prisma-access-200v-628-ztna-connector-b1-2-arm"
}
