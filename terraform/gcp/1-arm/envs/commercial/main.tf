
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "ztna-connector" {
  name           = var.vm_name
  machine_type   = var.vm_machine_type
  zone           = var.zone
  can_ip_forward = "true"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.vm_internet_subnet
  }

  network_interface {
    subnetwork = var.vm_data_center_subnet
  }

  metadata = {
    serial-port-enable = "true"
    cloudgenix         = format("General:\n  model: ion 200v\nLicense:\n  key: %s\n  secret: %s\n1:\n  role: PublicWAN\n  type: DHCP\n2:\n  role: LAN\n  type: DHCP\n", var.vm_license_key, var.vm_license_secret)
  }
}
