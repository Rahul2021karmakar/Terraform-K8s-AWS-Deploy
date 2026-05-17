# Terraform EKS Setup

This project creates a production-ready Amazon EKS cluster using modular Terraform.

## Structure

- `modules/vpc`: VPC and subnet creation
- `modules/iam`: IAM roles for EKS
- `modules/eks`: EKS cluster and node group
- `modules/addons`: EKS cluster addons
- `environments/dev`: Dev environment configurations

## Steps to Deploy

```bash
cd environments/dev
terraform init  # Initialize the Terraform configuration
terraform plan  # Plan the Terraform configuration
terraform apply # Apply the Terraform configuration
aws eks update-kubeconfig --region ap-south-1 --name servify-dev-cluster
# bash ../../service-deployment.sh
```
