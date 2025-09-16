variable "cloud" {
  description = "The cloud provider to use (e.g., aws, azure)"
  type        = string
  default     = "gcp"
}
variable "gcp_project_id" {
  description = "Google Kubernetes Service Cluster Name"
  type        = string
}

variable "gcp_cluster" {
  description = "Google Kubernetes Service Cluster service principal"
}

variable "gcp_region" {
  description = "Google Kubernetes Service Cluster service principal"
}

variable "gke_num_nodes" {
  description = "Google Kubernetes Service Cluster service principal"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS management"
  type        = string
  sensitive   = true
}


variable "deploy_postgres_gcp_k8s" {
  description = "Deploy Postgres on GKE"
  type        = bool
}

variable "deploy_redis_gcp_k8s" {
  description = "Deploy Redis on GKE"
  type        = bool
}

variable "deploy_neo4j_gcp_k8s" {
  description = "Deploy Neo4j on GKE"
  type        = bool
}

variable "deploy_kafka_gcp_k8s" {
  description = "Deploy Kafka on GKE"
  type        = bool
}

variable "deploy_rabbitmq_gcp_k8s" {
  description = "Deploy RabbitMQ on GKE"
  type        = bool
}


variable "deploy_argocd_gcp_k8s" {
  type    = bool

}
variable "deploy_elasticsearch_gcp_k8s" {
  type    = bool

}


variable "github_repository_url_gcp" {
  type        = string
  description = "GitHub repository URL for ArgoCD in GCP"
  default     = "https://github.com/example/gcp-repo.git"
}

variable "github_username_gcp" {
  type        = string
  description = "GitHub username for ArgoCD in GCP"
  default     = "gcp-user"
}

variable "github_token_gcp" {
  type        = string
  description = "GitHub personal access token for ArgoCD in GCP"
  default     = "changeme-gcp-token"
}
