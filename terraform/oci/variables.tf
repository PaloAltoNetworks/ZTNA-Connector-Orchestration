#Variables declared in this file must be declared in the marketplace.yaml
#Provide a description to your variables.

############################
#  Hidden Variable Group   #
############################
variable "tenancy_ocid" {
}

variable "region" {
}

###############################################################################
#  Marketplace Image Listing - information available in the Partner portal    #
###############################################################################
variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = false
}

variable "mp_listing_id" {
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaa2ctnvy3yio3yc4kezi57xvzh6vbxdeurypfe3uw7f4xld3lhhbjq"
  description = "Marketplace Listing OCID"
}

variable "mp_listing_resource_id" {
  default     = "ocid1.image.oc1..aaaaaaaam7laq5e5xe3wea5yir5naqpl6s6btuwchsxyfaxxvl7uuvr3kmaa"
  description = "Marketplace Listing Image OCID"
}

variable "mp_listing_resource_version" {
  default     = "6.2.7-ztna-connector-b8"
  description = "Marketplace Listing Package/Resource Version"
}

############################
#  Custom Image           #
#  sase default     = "ocid1.image.oc1.phx.aaaaaaaab7yxokubezefvazsvcpixp2srzdb2gsxiutnb2tb5tjxvfjuksvq"
#  ashburn  default     = "ocid1.image.oc1.iad.aaaaaaaaa6gfbjvhdbtrbxm6dcyjiuebsczi6qcogwp5dkm7dmderdw354za"
#  ashburn  correct one     = "ocid1.image.oc1.iad.aaaaaaaatenwg3jehjnlhpffcpoq5a77djeyqbrnlxyseplgzzc6xc3hvjyq""
# phx     = "ocid1.image.oc1.phx.aaaaaaaau2vbeebpr6s3uonnxp2vpamdskbeywanbqcc5fkvdlofogxg2sna"
############################
variable "custom_image_id" {
  default     = "ocid1.image.oc1.phx.aaaaaaaal4rimyzwuftu45y4xnvngq7sauthxg25wvxpboxeqejwjez3ztgq"
  description = "Custom Image OCID"
}

############################
#  Compute Configuration   #
############################

variable "vm_display_name" {
  description = "Instance Name"
  default     = "ztna-connector-vm"
}

variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard.E5.Flex"
}

variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain name, if non-empty takes precedence over availability_domain_number"
}

variable "availability_domain_number" {
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
}

############################
#  Network Configuration   #
############################

variable "internet_subnet_id" {
  description = "The OCID of the internet facing subnet for the NIC #1."
  type        = string
}

variable "data_center_subnet_id" {
  description = "The OCID of the data center facing subnet for the NIC #2."
  type        = string
  default     = null # Setting a default of `null` is important as the variable might not be provided.
}

variable "number_of_nics" {
  description = "The number of network interfaces (1 or 2)."
  type        = string
  default     = "1"
  validation {
    condition     = contains(["1", "2"], var.number_of_nics)
    error_message = "The number_of_nics variable must be either '1' or '2'."
  }
}

############################
# Additional Configuration #
############################

variable "compartment_ocid" {
  description = "Compartment where Compute and Marketplace subscription resources will be created"
}

variable "tag_key_name" {
  description = "Free-form tag key name"
  default     = "paloaltonetworks-ztna"
}

variable "tag_value" {
  description = "Free-form tag value"
  default     = "ztna-connector-template"
}

############################
# Additional Configuration #
############################

# ztna connector license key is required.
variable "vm_license_key" {
  type = string
}

# ztna connector license secret is required.
variable "vm_license_secret" {
  type = string
}

