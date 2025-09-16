# Namespace for Cassandra
resource "kubernetes_namespace" "cassandra" {
  metadata {
    name = "cassandra"
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

# Random password for Cassandra
resource "random_password" "cassandra" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.cassandra]
}

# Helm release for Cassandra
resource "helm_release" "cassandra" {
  count      = var.deploy_cassandra_gcp_k8s ? 1 : 0
  name       = "cassandra"
  namespace  = kubernetes_namespace.cassandra.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "cassandra"
  version    = "12.3.11"

  set = [
    {
      name  = "replicaCount"
      value = "1"
    },
    {
      name  = "persistence.size"
      value = "10Gi"
    },
    {
      name  = "auth.enabled"
      value = "false"
    }
  ]

  depends_on = [kubernetes_namespace.cassandra]
}
