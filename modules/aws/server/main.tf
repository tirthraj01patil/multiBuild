terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region_server
  access_key = var.aws_access_key_server
  secret_key = var.aws_secret_key_server
}
