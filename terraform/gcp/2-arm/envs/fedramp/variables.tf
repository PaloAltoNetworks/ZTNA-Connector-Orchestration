
# gcp project Id is required.
variable "project_id" {
  type = string
}

variable "region" {
  type    = string
}

variable "zone" {
  type    = string
}

# ztna connector vm name is required.
variable "vm_name" {
  type = string
}

# ztna connector port 1 subnet is required.
variable "vm_internet_subnet" {
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
  default = "projects/paloaltonetworksgcp-public/global/images/prisma-access-200v-625-ztna-connector-b10-1arm"
}
