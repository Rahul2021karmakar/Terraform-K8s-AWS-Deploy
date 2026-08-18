variable "cluster_name" {}
variable "ebs_csi_version" {
  default = "v1.46.0-eksbuild.1"
}
variable "alb_version" {
  default = "v1.26.0-eksbuild.1"
}
# variable "ebs_csi_role_arn" {}

variable "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL (issuer)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.35"
}
