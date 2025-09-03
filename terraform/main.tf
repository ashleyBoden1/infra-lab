# -------------------------
# VPC + Subnets
# -------------------------
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_a" {
  name          = "${var.network_name}-subnet-a"
  ip_cidr_range = var.subnet_a_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "${var.network_name}-subnet-b"
  ip_cidr_range = var.subnet_b_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
}

# -------------------------
# Firewall rules
# -------------------------

# Allow internal traffic (TCP/UDP/ICMP) within 10.10.0.0/16
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-10-10-0-0-16"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/16"]
}

# Allow SSH from your IP to either VM (safer than 0.0.0.0/0)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-from-my-ip"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = [var.my_ip_cidr]
  target_tags   = ["ssh"]
}

# -------------------------
# (Optional) Cloud NAT via Cloud Router
# Lets VMs without external IPs reach internet. We'll still
# give our VMs external IPs for easy SSH, but this prepares you
# for private-only VMs later.
# -------------------------

resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# -------------------------
# VMs (one per subnet)
# -------------------------
resource "google_compute_instance" "vm_a" {
  name         = var.vm_a_name
  machine_type = var.machine_type
  zone         = var.zone_a
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_a.name

    # External IP for easy SSH during the lab
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y traceroute
  EOT
}

resource "google_compute_instance" "vm_b" {
  name         = var.vm_b_name
  machine_type = var.machine_type
  zone         = var.zone_b
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_b.name

    # External IP for easy SSH during the lab
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y traceroute
  EOT
}
