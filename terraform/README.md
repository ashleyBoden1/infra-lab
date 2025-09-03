# Terraform Lab – GCP VM + Network

This is a simple Terraform project that demonstrates Infrastructure as Code (IaC) on **Google Cloud Platform**.

## What it does
- Creates a new **VPC network**
- Deploys a **Compute Engine VM** (Debian 11, `e2-micro`)
- Attaches the VM to the VPC
- Configures external access (via default access config)

## Files
- `main.tf` → main Terraform configuration

## Usage
1. Initialize Terraform:
   ```bash
   terraform init

🔐 Accessing Private VMs via Bastion

This lab uses a bastion host to provide secure access to private VMs.

VMs (dev, prod, shared) → no external IPs

Bastion host → only VM with an external IP, lives in the shared subnet

Firewall rules:

Allow SSH from your IP → bastion

Allow SSH from bastion → dev/prod/shared (private IPs)

Internal traffic rules still enforce isolation (dev ↔ prod blocked, both ↔ shared allowed)

Steps to Connect

SSH into the bastion

gcloud compute ssh vm-bastion --zone=us-central1-c


Or, if using PuTTY, connect to the bastion’s external IP (shown in Terraform outputs).

From the bastion → connect to private VMs
Use private IPs from Terraform outputs:

ssh <VM_A_PRIVATE_IP>   # dev
ssh <VM_B_PRIVATE_IP>   # prod
ssh <VM_C_PRIVATE_IP>   # shared


Verify segmentation rules

dev ↔ prod = ❌ blocked

dev ↔ shared = ✅ allowed

prod ↔ shared = ✅ allowed