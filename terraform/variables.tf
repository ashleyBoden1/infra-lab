variable "project_id" {
  description = "Your GCP project ID (required)"
  type        = string
}

variable "region" {
  description = "Default region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Default zone"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "terraform-network"
}

variable "vm_name" {
  description = "Compute Engine VM name"
  type        = string
  default     = "terraform-vm"
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "e2-micro"
}
