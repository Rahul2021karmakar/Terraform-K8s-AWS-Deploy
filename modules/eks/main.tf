# EKS cluster
resource "aws_eks_cluster" "main" {
  name     = var.project
  role_arn = var.cluster_role_arn
  version  = "1.32"

  vpc_config {
    subnet_ids                = var.subnet_ids
    endpoint_private_access   = true
    endpoint_public_access    = true
    public_access_cidrs       = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    { "alpha.eksctl.io/cluster-oidc-enabled" = "true" }
  )

  # depends_on = [ aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy ]
  
}

# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = var.cluster_role_name
# }

# EKS cluster security group
resource "aws_security_group" "eks_cluster" {
  name = "${var.project}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-cluster-sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description               = "Allow worker nodes to communicate with the cluster API Server"
  from_port                 = 443
  to_port                   = 443
  security_group_id         = aws_security_group.eks_cluster.id
  source_security_group_id  = aws_security_group.eks_nodes.id
  protocol                  = "tcp"
  type                      = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description               = "Allow cluster API Server to communicate with the worker nodes"
  from_port                 = 1024
  to_port                   = 65535
  security_group_id         = aws_security_group.eks_cluster.id
  source_security_group_id  = aws_security_group.eks_nodes.id
  protocol                  = "tcp"
  type                      = "egress"
}


resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  ami_type        = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type   = "ON_DEMAND"   # ON_DEMAND, SPOT
  instance_types  = ["t3a.medium"] # ["t3a.medium","t3a.large"] / ["t3a.large"]

  tags = merge(
    var.tags
  )

  # depends_on = [
  #   aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
  #   aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  #   aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  #  ]

  lifecycle {
    create_before_destroy = false
    ignore_changes = [ 
      scaling_config["desired_size"],
     ]
  }

}

# EKS Node group security group
resource "aws_security_group" "eks_nodes" {
  name          = "${var.project}-node-sg"
  description   = "Security group for all nodes in the cluster"
  vpc_id        = var.vpc_id

  egress = [
    {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
  ]

  tags = {
    Name                                           = "${var.project}-node-sg"
    "kubernetes.io/cluster/${var.project}" = "owned"
  } 

}

resource "aws_security_group_rule" "nodes_internal" {
  description               = "Allow nodes to communicate with each other"
  from_port                 = 0
  to_port                   = 65535
  protocol                  = "-1"
  security_group_id         = aws_security_group.eks_nodes.id
  source_security_group_id  = aws_security_group.eks_nodes.id
  type                       = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description                 = "Allow worker kubeletes and pods to receive communication from the cluster control plane"
  from_port                   = 1025
  to_port                     = 65535
  protocol                    = "tcp"
  security_group_id           = aws_security_group.eks_nodes.id
  source_security_group_id    = aws_security_group.eks_cluster.id
  type                        = "ingress"
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.main.certificate_authority
}