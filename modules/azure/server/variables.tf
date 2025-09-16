
variable "appId_server" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password_server" {
  description = "Azure Kubernetes Service Cluster password"
}

variable "project_server" {
  description = "Name of the project/VM"
  type        = string
}

variable "size_server" {
  description = "Azure VM size"
  type        = string
}

variable "location_server" {
  description = "Azure region"
  type        = string
}

variable "deploy_postgres_azure" {
  type = bool
}

variable "deploy_redis_azure" {
  type = bool
}

variable "deploy_kafka_azure" {
  type = bool
}

variable "deploy_rabbitmq_azure" {
  type = bool
}

variable "deploy_neo4j_azure" {
  type = bool
}