
variable "aws_access_key_server" {
  description = "The AWS access key"
  type        = string
}

variable "aws_secret_key_server" {
  description = "The AWS secret key"
  type        = string
}

variable "project_name_server" {
  description = "The name of the project"
  type        = string
}

variable "instance_type_server" {
  description = "The type of EC2 instance to use"
  type        = string
}

variable "region_server" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "deploy_postgres_aws" {
  type = bool
}

variable "deploy_redis_aws" {
  type = bool
}

variable "deploy_kafka_aws" {
  type = bool
}

variable "deploy_rabbitmq_aws" {
  type = bool
}

variable "deploy_neo4j_aws" {
  type = bool
}
