output "vm_a_private_ip" {
  value       = google_compute_instance.vm_a.network_interface[0].network_ip
  description = "VM A private IP"
}

output "vm_b_private_ip" {
  value       = google_compute_instance.vm_b.network_interface[0].network_ip
  description = "VM B private IP"
}

output "vm_a_external_ip" {
  value       = google_compute_instance.vm_a.network_interface[0].access_config[0].nat_ip
  description = "VM A external IP"
}

output "vm_b_external_ip" {
  value       = google_compute_instance.vm_b.network_interface[0].access_config[0].nat_ip
  description = "VM B external IP"
}
