variable "project" {}

variable "subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {}

# variable "cluster_role_name" {}

variable "node_role_arn" {}

# variable "node_role_name" {}

variable "tags" {}

variable "vpc_id" {}