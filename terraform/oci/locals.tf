locals {

  # Logic to use AD name provided by user input on ORM or to lookup for the AD name when running from CLI
  availability_domain = (var.availability_domain_name != "" ? var.availability_domain_name : data.oci_identity_availability_domain.ad.name)

  # Logic to choose a custom image or a marketplace image.
  compute_image_id = var.mp_subscription_enabled ? var.mp_listing_resource_id : var.custom_image_id

  # Local to control subscription to Marketplace image.
  mp_subscription_enabled = var.mp_subscription_enabled ? 1 : 0

  # Marketplace Image listing variables - required for subscription only
  listing_id               = var.mp_listing_id
  listing_resource_id      = var.mp_listing_resource_id
  listing_resource_version = var.mp_listing_resource_version

  metadata = var.number_of_nics == "2" ? format("General:\n  model: ion 200v\nLicense:\n  key: %s\n  secret: %s\n1:\n  role: PublicWAN\n  type: DHCP\n2:\n  role: LAN\n  type: STATIC\n", var.vm_license_key, var.vm_license_secret) : format("General:\n  model: ion 200v\nLicense:\n  key: %s\n  secret: %s\n1:\n  role: PublicWAN\n  type: DHCP\n", var.vm_license_key, var.vm_license_secret)

}
