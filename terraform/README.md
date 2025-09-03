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
