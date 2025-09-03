output "vm_a_private_ip" {
  value       = google_compute_instance.vm_a.network_interface[0].network_ip
  description = "VM A private IP"
}

output "vm_b_private_ip" {
  value       = google_compute_instance.vm_b.network_interface[0].network_ip
  description = "VM B private IP"
}

output "vm_c_private_ip" {
  value       = google_compute_instance.vm_c.network_interface[0].network_ip
  description = "VM C private IP"
}

output "bastion_private_ip" {
  value       = google_compute_instance.bastion.network_interface[0].network_ip
  description = "Bastion private IP"
}

output "bastion_external_ip" {
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
  description = "Bastion external IP"
}

output "ssh_to_bastion_hint" {
  value       = "gcloud compute ssh ${var.bastion_name} --zone=${var.zone_bastion}"
  description = "Convenient gcloud SSH command"
}