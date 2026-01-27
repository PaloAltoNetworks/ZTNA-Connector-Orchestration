output "ip_address" {
  value = google_compute_instance.ztna-connector.network_interface[0].network_ip
  description = "The private IP address of the connector's internet/data center interface."
}

output "instance_id" {
  value = google_compute_instance.ztna-connector.instance_id
  description = "The connector's unique instance ID."
}

output "instance_name" {
  value = google_compute_instance.ztna-connector.name
  description = "The name of the connector."
}

output "zone" {
  value = google_compute_instance.ztna-connector.zone
  description = "The zone where the connector is located."
}

output "machine_type" {
  value = google_compute_instance.ztna-connector.machine_type
  description = "The machine type of the connector."
}

output "metadata" {
  value = google_compute_instance.ztna-connector.metadata
  description = "Custom metadata for the connector."
}
