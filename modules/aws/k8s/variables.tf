variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zones_count" {
  description = "Number of availability zones"
  type        = number
}

variable "subnet_cidr_bits" {
  description = "Number of subnet bits for the CIDR"
  type        = number
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}

variable "desired_size" {
  description = "EKS desired_size"
  type        = number
}

variable "max_size" {
  description = "EKS max_size"
  type        = number
}

variable "min_size" {
  description = "EKS min_size"
  type        = number
}

# Database Deployment Flags
variable "deploy_postgres_aws_k8s" {
  description = "Deploy PostgreSQL on AWS EKS"
  type        = bool
}

variable "deploy_redis_aws_k8s" {
  description = "Deploy Redis on AWS EKS"
  type        = bool
}

variable "deploy_kafka_aws_k8s" {
  description = "Deploy Kafka on AWS EKS"
  type        = bool
}

variable "deploy_rabbitmq_aws_k8s" {
  description = "Deploy RabbitMQ on AWS EKS"
  type        = bool
}

variable "deploy_neo4j_aws_k8s" {
  description = "Deploy Neo4j on AWS EKS"
  type        = bool
}


variable "deploy_argocd_aws_k8s" {
  description = "Deploy Argo CD on AWS EKS"
  type        = bool
}

variable "deploy_elasticsearch_aws_k8s" {
  description = "Deploy Elasticsearch on AWS EKS"
  type        = bool
}

variable "deploy_cassandra_aws_k8s" {
  description = "Deploy Cassandra on AWS EKS"
  type        = bool
}

# GitHub repository credentials for AWS
variable "github_repository_url_aws" {
  description = "GitHub repository URL for AWS ArgoCD"
  type        = string
  default     = "https://github.com/example/aws-repo.git"
}

variable "github_username_aws" {
  description = "GitHub username for AWS ArgoCD"
  type        = string
  default     = "aws-user"
}

variable "github_token_aws" {
  description = "GitHub token for AWS ArgoCD"
  type        = string
  default     = "aws-secret-token"
}
