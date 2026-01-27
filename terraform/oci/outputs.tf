###
# compute.tf outputs
###

output "instance_id" {
  value = oci_core_instance.ztna-connector-vm.id
}

output "instance_private_ip" {
  value = oci_core_instance.ztna-connector-vm.private_ip
}

###
# network.tf outputs
###

output "internet_subnet_id" {
  value = var.internet_subnet_id
}
output "data_center_subnet_id" {
  value = var.data_center_subnet_id
}

###
# image_subscription.tf outputs
###

output "subscription" {
  value = data.oci_core_app_catalog_subscriptions.mp_image_subscription.*.app_catalog_subscriptions
}
