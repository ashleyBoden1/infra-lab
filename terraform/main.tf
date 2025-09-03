provider "google" {
  project = "speedy-realm-470614-f8"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# Static external IP for the VM
resource "google_compute_address" "vm_ip" {
  name   = "terraform-vm-ip"
  region = "us-central1"
}

# Firewall to allow SSH (22) and HTTP (80) to VMs tagged "web"
resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]
}

# VM
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  # Tag must match firewall target_tags
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.vm_ip.address # attach static IP
    }
  }

  # Optional: simple startup script to install nginx
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOT
}
