
# IAM Policy Document for Trust Relationship
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      # identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
      identifiers = [var.oidc_provider_arn]

    }

    condition {
      test = "StringEquals"
      # variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

# Create the IAM Role
resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

# Attach required policy
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# # 5. Output the role ARN
# output "ebs_csi_driver_role_arn" {
#   value = aws_iam_role.ebs_csi.arn
# }

# EBS CSI
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_version
  service_account_role_arn = aws_iam_role.ebs_csi.arn
}

# kube-proxy
data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = var.cluster_name
  addon_name    = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# resource "aws_eks_addon" "alb_controller" {
#   cluster_name             = var.cluster_name
#   addon_name               = "vpc-cni" # Note: ALB controller is not an EKS addon but deployed via Helm; for example purposes
#   addon_version            = var.alb_version
# #   resolve_conflicts        = "OVERWRITE"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
# }

output "ebs_csi_addon_arn" {
  value = aws_eks_addon.ebs_csi.arn
}
