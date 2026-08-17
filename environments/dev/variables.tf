variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  # description = "Name of the project deployment."
  type    = string
  default = "cuddlyduddly"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project" = "cuddlyduddly"
  }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}


