output "vm_external_ip" {
  description = "Public IP of the VM"
  value       = google_compute_address.vm_ip.address
}

output "vm_name" {
  description = "Name of the VM"
  value       = google_compute_instance.vm_instance.name
}

output "ssh_hint" {
  description = "Example SSH command (replace with your username/key)"
  value       = "ssh <your-username>@${google_compute_address.vm_ip.address}"
}
