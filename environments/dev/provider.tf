terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "cuddlyduddly-terraform-state"
    key          = "eks/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
    profile = "cuddlyduddly"
  }
}

provider "aws" {
  region  = var.region
  profile = "cuddlyduddly"
}