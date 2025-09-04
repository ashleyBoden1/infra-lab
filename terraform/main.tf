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

resource "google_compute_subnetwork" "subnet_c" {
  name          = "${var.network_name}--subnet-c"
  ip_cidr_range = var.subnet_c_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
}

# -------------------------
# Firewall rules
# -------------------------

# SSH from you IP to VMs tagged "ssh"
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

# Allow DEV -> SHARED
resource "google_compute_firewall" "allow_dev_to_shared" {
  name    = "allow-dev-to-shared"
  network = google_compute_network.vpc.name

  allow { protocol = "all" }
  direction     = "INGRESS"
  source_ranges = [var.subnet_a_cidr] # DEV subnet
  target_tags   = ["shared"]          # only VMs tagged shared
}

# Allow SHARED -> DEV
resource "google_compute_firewall" "allow_shared_to_dev" {
  name    = "allow-shared-to-dev"
  network = google_compute_network.vpc.name

  allow { protocol = "all" }
  direction     = "INGRESS"
  source_ranges = [var.subnet_c_cidr] # SHARED subnet
  target_tags   = ["dev"]             # only VMs tagged dev
}

# Allow PROD -> SHARED
resource "google_compute_firewall" "allow_prod_to_shared" {
  name    = "allow-prod-to-shared"
  network = google_compute_network.vpc.name

  allow { protocol = "all" }
  direction     = "INGRESS"
  source_ranges = [var.subnet_b_cidr] # PROD subnet
  target_tags   = ["shared"]
}

# Allow SHARED -> PROD
resource "google_compute_firewall" "allow_shared_to_prod" {
  name    = "allow-shared-to-prod"
  network = google_compute_network.vpc.name

  allow { protocol = "all" }
  direction     = "INGRESS"
  source_ranges = [var.subnet_c_cidr] # SHARED subnet
  target_tags   = ["prod"]
}

# Allow SSH from your IP into bastion
resource "google_compute_firewall" "allow_ssh_to_bastion" {
  name    = "allow-ssh-to-bastion"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = [var.my_ip_cidr]
  target_tags   = ["bastion"]
}

# allow SSH from bastion (private IP) → dev/prod/shared
resource "google_compute_firewall" "allow_ssh_from_bastion_internal" {
  name    = "allow-ssh-from-bastion-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"
  # Only the bastion's NIC IP can initiate SSH to others
  source_ranges = ["${google_compute_instance.bastion.network_interface[0].network_ip}/32"]

  # Let bastion reach all tiers (dev/prod/shared)
  target_tags = ["dev", "prod", "shared"]
}

# Allow LB health check
resource "google_compute_firewall" "allow_lb_healthcheck" {
  name    = "allow-lb-healthcheck"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # GCP LB health check ranges
  target_tags   = ["lb-backend"]
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
  tags         = ["dev", "ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_a.name
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
  tags         = ["prod", "ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_b.name
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y traceroute
  EOT
}

resource "google_compute_instance" "vm_c" {
  name         = var.vm_c_name
  machine_type = var.machine_type
  zone         = var.zone_c
  tags         = ["shared", "ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_c.name
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y traceroute net-tools
  EOT
}

resource "google_compute_instance" "bastion" {
  name         = var.bastion_name
  machine_type = var.machine_type
  zone         = var.zone_bastion
  tags         = ["bastio", "ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_c.name
    access_config {}
  }

  metadata_startup_script = <<-EOT
      #!/bin/bash
      apt-get update -y
      apt-get install -y traceroute net-tools
    EOT
}

# -------------------------
# Load balancer VMs
# -------------------------

resource "google_compute_instance" "lb_vm1" {
  name         = var.lb_vm1_name
  machine_type = var.machine_type
  zone         = var.zone_a
  tags         = ["lb-backend"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork  = google_compute_subnetwork.subnet_a.name
    access_config{}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "Hello from VM1 in zone ${var.zone_a}" > /var/www/html/index.html
    systemctl restart nginx
  EOT
}

resource "google_compute_instance" "lb_vm2" {
  name         = var.lb_vm2_name
  machine_type = var.machine_type
  zone         = var.zone_b
  tags         = ["lb-backend"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_b.name
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "Hello from VM2 in zone ${var.zone_b}" > /var/www/html/index.html
    systemctl restart nginx
  EOT
}

# -------------------------
# Load balancer resources
# -------------------------
# Instance group managers for LB (wraps the VMs into groups)
resource "google_compute_instance_group" "lb_vm1_group" {
  name      = "${var.lb_vm1_name}-group"
  zone      = var.zone_a
  instances = [google_compute_instance.lb_vm1.self_link]
  network   = google_compute_network.vpc.id
}

resource "google_compute_instance_group" "lb_vm2_group" {
  name      = "${var.lb_vm2_name}-group"
  zone      = var.zone_b
  instances = [google_compute_instance.lb_vm2.self_link]
  network   = google_compute_network.vpc.id
}

# Backend service
resource "google_compute_backend_service" "default" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_http_health_check.default.self_link]

  backend {
    group = google_compute_instance_group.lb_vm1_group.self_link
  }

  backend {
    group = google_compute_instance_group.lb_vm2_group.self_link
  }
}

# Health check
resource "google_compute_http_health_check" "default" {
  name               = "basic-http-health-check"
  request_path       = "/"
  port               = 80
  check_interval_sec = 5
  timeout_sec        = 5
}

# URL map
resource "google_compute_url_map" "default" {
  name            = "web-map"
  default_service = google_compute_backend_service.default.self_link
}

# Target HTTP proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.self_link
}

# Global forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-forwarding-rule"
  target                = google_compute_target_http_proxy.default.self_link
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
}
