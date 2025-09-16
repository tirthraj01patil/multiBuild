output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

########################################
# Database Outputs - Azure
########################################

output "postgres_service" {
  value = var.deploy_postgres_azure_k8s ? "postgresql.default.svc.cluster.local:5431" : null
}

output "redis_service" {
  value = var.deploy_redis_azure_k8s ? "redis-master.default.svc.cluster.local:6379" : null
}

output "kafka_service" {
  value = var.deploy_kafka_azure_k8s ? "kafka.default.svc.cluster.local:9092" : null
}

output "rabbitmq_service" {
  value = var.deploy_rabbitmq_azure_k8s ? "rabbitmq.default.svc.cluster.local:5672" : null
}

output "neo4j_service" {
  value = var.deploy_neo4j_azure_k8s ? "neo4j.default.svc.cluster.local:7687" : null
}
