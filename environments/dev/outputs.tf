# output "cluster_name" {
#   value = aws_eks_cluster.main.name
#   # value = module.eks.aws_eks_cluster.main.name
# }

# output "cluster_endpoint" {
#   value = aws_eks_cluster.main.cluster_endpoint
#   # value = module.eks.aws_eks_cluster.main.cluster_endpoint
# }

# output "cluster_ca_certificate" {
#   value = aws_eks_cluster.this.certificate_authority[0].data
#   # value = module.eks.aws_eks_cluster.main.certificate_authority[0].data
# }


output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_ca_certificate
}
