
locals {
  oidc_issuer = replace(var.oidc_provider_url, "https://", "")
}

resource "aws_iam_role" "controller" {
  name = "${var.project}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer}:sub" = "system:serviceaccount:karpenter:karpenter"
        }
      }
    }]
  })
}

resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.karpenter_node_role_name}"
  type          = "EC2_LINUX"
}

output "karpenter_controller_role_arn" {
  value = aws_iam_role.controller.arn
}

output "karpenter_controller_role_name" {
  value = aws_iam_role.controller.name
}
