variable "project_id" {
  description = "speedy-realm-470614-f8"
  type        = string
}

variable "region" {
  description = "Default region for subnets/routers/NAT"
  type        = string
  default     = "us-central1"
}

variable "zone_a" {
  description = "Zone for VM A"
  type        = string
  default     = "us-central1-a"
}

variable "zone_b" {
  description = "Zone for VM B"
  type        = string
  default     = "us-central1-b"
}

variable "zone_c" {
  description = "Zone for VM C"
  type        = string
  default     = "us-central1-c"
}

variable "network_name" {
  description = "VPC name"
  type        = string
  default     = "net-lab"
}

variable "subnet_a_cidr" {
  description = "CIDR for Subnet A"
  type        = string
  default     = "10.10.1.0/24"
}

variable "subnet_b_cidr" {
  description = "CIDR for Subnet B"
  type        = string
  default     = "10.10.2.0/24"
}

variable "subnet_c_cidr" {
  description = "CIDR for subnet C (shared services)"
  type        = string
  default     = "10.10.3.0/24"
}

variable "vm_a_name" {
  description = "VM A name"
  type        = string
  default     = "vm-a"
}

variable "vm_b_name" {
  description = "VM B name"
  type        = string
  default     = "vm-b"
}

variable "vm_c_name" {
  description = "VM C name"
  type        = string
  default     = "vm-shared"
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "e2-micro"
}

# For SSH lab convenience; replace with your public IP in CIDR
# format, e.g., "203.0.113.45/32". For quick lab you can leave
# as 0.0.0.0/0 but it's not secure for real use.
variable "my_ip_cidr" {
  description = "Your public IP in CIDR to allow SSH"
  type        = string
  default     = "0.0.0.0/0"
}
