variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}

variable "project_name" {
  description = "Azure Kubernetes Service Cluster Name"
}

variable "azure_region" {
  description = "Azure Kubernetes Service Region Name"
}

variable "azure_node_count" {
  description = "Number of nodes in Azure Kubernetes Service Cluster"
}

variable "azure_vm_size" {
  description = "VM size for nodes in Azure Kubernetes Service Cluster"
}

# Database flags
variable "deploy_postgres_azure_k8s" {
  type        = bool
  description = "Deploy Postgres inside AKS"
}

variable "deploy_redis_azure_k8s" {
  type        = bool
  description = "Deploy Redis inside AKS"
}

variable "deploy_kafka_azure_k8s" {
  type        = bool
  description = "Deploy Kafka inside AKS"
}

variable "deploy_rabbitmq_azure_k8s" {
  type        = bool
  description = "Deploy RabbitMQ inside AKS"
}

variable "deploy_neo4j_azure_k8s" {
  type        = bool
  description = "Deploy Neo4j inside AKS"
}


variable "deploy_argocd_azure_k8s" {
  type        = bool
  description = "Deploy Argo CD inside AKS"
}

variable "deploy_elasticsearch_azure_k8s" {
  type        = bool
  description = "Deploy Elasticsearch inside AKS"
}

