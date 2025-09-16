# ======================
# Terraform Settings
# ======================
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

# ======================
# AWS Provider
# ======================
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = merge(
      {
        Environment = terraform.workspace
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}

# ======================
# EKS Auth Data
# ======================
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}
