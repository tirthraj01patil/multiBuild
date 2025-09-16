variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region-gcp" {
  description = "GCP region for the VM"
  type        = string
}

variable "zone-gcp" {
  description = "GCP zone for the VM"
  type        = string
}

variable "instance_name" {
  description = "Name of the GCP VM instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the GCP VM"
  type        = string
}

variable "username_gcp" {
  description = "SSH username for GCP VM"
  type        = string
}

variable "deploy_postgres_gcp" {
  description = "Install PostgreSQL"
  type        = bool
}

variable "deploy_redis_gcp" {
  description = "Install Redis"
  type        = bool
}

variable "deploy_kafka_gcp" {
  description = "Install Kafka"
  type        = bool
}

variable "deploy_rabbitmq_gcp" {
  description = "Install RabbitMQ"
  type        = bool
}

variable "deploy_neo4j_gcp" {
  description = "Install Neo4j"
  type        = bool
}
