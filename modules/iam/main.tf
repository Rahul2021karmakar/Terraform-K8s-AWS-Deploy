# EKS cluster IAM role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project}-eks-cluster-role"
  
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attaching role with AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# data "aws_iam_policy_document" "eks_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }
#   }
# }

# EKS Node IAM role
resource "aws_iam_role" "node" {
  name = "${var.project}-eks-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attaching node role with AmazonEKSWorkerNodePolicy
# resource "aws_iam_role_policy_attachment" "eks_node_policy" {
#   policy_arn = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"]
#   role = aws_iam_role.node
# }

variable "eks_node_policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  ]
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  for_each   = toset(var.eks_node_policies)
  role       = aws_iam_role.node.name
  policy_arn = each.value
}


output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_cluster_role_name" {
  value = aws_iam_role.eks_cluster.name
}

output "eks_node_role_arn" {
  value = aws_iam_role.node.arn
}

output "eks_node_role_name" {
  value = aws_iam_role.node.name
}