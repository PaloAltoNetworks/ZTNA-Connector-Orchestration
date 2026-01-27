terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0"
    }
  }
}

provider "vsphere" {
  # Provider configuration can be set via environment variables:
  # VSPHERE_SERVER, VSPHERE_USER, VSPHERE_PASSWORD
  # Or specified here:
  # vsphere_server = var.vsphere_server
  # user           = var.vsphere_user
  # password       = var.vsphere_password
  # allow_unverified_ssl = var.allow_unverified_ssl
}
