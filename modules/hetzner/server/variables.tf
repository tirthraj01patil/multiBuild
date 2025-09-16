variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "hetzner-server"
}

variable "server_type" {
  description = "Type of the server (e.g., cpx31, cx21)"
  type        = string
}
variable "location" {
  description = "Hetzner location (fsn1, nbg1, hel1, ash)"
  type        = string
  default     = "fsn1"
}

variable "deploy_postgres_hetzner" {
  type    = bool
  default = true
}

variable "deploy_redis_hetzner" {
  type    = bool
  default = false
}

variable "deploy_kafka_hetzner" {
  type    = bool
  default = false
}

variable "deploy_rabbitmq_hetzner" {
  type    = bool
  default = false
}

variable "deploy_neo4j_hetzner" {
  type    = bool
  default = false
}
