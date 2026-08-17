# Terraform K8s AWS Deploy

## Repository Overview

This repository provisions an AWS EKS cluster and the supporting infrastructure using modular Terraform.

## Repository Structure

- `environments/`
  - Contains environment-specific Terraform configuration.
  - `dev/` is the current example environment with `main.tf`, `provider.tf`, `variables.tf`, `outputs.tf`, and `terraform.tfvars`.

- `modules/`
  - Reusable Terraform modules for AWS infrastructure and Kubernetes integration.
  - `vpc/` builds the networking stack.
  - `iam/` defines IAM roles and policies.
  - `oidc/` configures OIDC provider for IRSA.
  - `eks/` creates the EKS cluster and node groups.
  - `addons/` deploys optional cluster add-ons or service integrations.

## Folder and File Meanings

### `environments/dev/`
- `main.tf` — root module wiring; connects modules and passes environment-specific inputs.
- `provider.tf` — AWS provider configuration (`region`, `profile`, required providers).
- `variables.tf` — environment variables definitions.
- `terraform.tfvars` — actual values for the development environment.
- `outputs.tf` — exported values such as cluster endpoint, CA, and names.
- `plan-changes.txt` — notes or recorded plan changes for this environment.

### `modules/vpc/`
- `main.tf` — creates VPC, public/private subnets, Internet Gateway, NAT Gateway, route tables, and security groups.
- `variables.tf` — input values for VPC CIDR, AZ count, subnet sizes, etc.
- `outputs.tf` — provides `vpc_id`, `public_subnet_ids`, `private_subnet_ids`.

### `modules/iam/`
- `main.tf` — creates IAM roles for the EKS cluster and nodes.
- `variables.tf` — receives project name and policy ARNs.
- `outputs.tf` — exposes cluster and node role ARNs/names.

### `modules/eks/`
- `main.tf` — creates `aws_eks_cluster` and `aws_eks_node_group`.
- `variables.tf` — accepts VPC subnet IDs, IAM role ARNs, and tags.
- `outputs.tf` — exposes the cluster name, endpoint, and CA certificate.

### `modules/oidc/`
- `main.tf` — creates an `aws_iam_openid_connect_provider` for the cluster.
- `variables.tf` — accepts `cluster_name`.
- `outputs.tf` — exposes OIDC provider ARN and URL.

### `modules/addons/`
- `main.tf` — creates addon IAM roles and installs EKS addons like EBS CSI.
- `variables.tf` — accepts cluster name, OIDC provider details, addon versions.
- `outputs.tf` — exports addon ARNs or role values.

## Flow Structure

The deployment follows this logical order:

1. **Network layer**
   - `modules/vpc` builds network infrastructure first.
   - Creates subnets, gateways, routes, and security groups.

2. **IAM layer**
   - `modules/iam` builds IAM roles and policy attachments.
   - Provides role ARNs to the EKS module.

3. **EKS cluster layer**
   - `modules/eks` creates the cluster using VPC networking and IAM roles.
   - Creates a managed node group in private subnets.

4. **OIDC provider**
   - `modules/oidc` creates the OIDC identity provider after the cluster exists.
   - Enables IRSA for service accounts used by addons.

5. **Addons layer**
   - `modules/addons` creates addon-specific IAM roles and installs addons.
   - Requires both cluster and OIDC provider to be ready.

## Terraform Workflow

From `environments/dev`:

```bash
cd environments/dev
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan