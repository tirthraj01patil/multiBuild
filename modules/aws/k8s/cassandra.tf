resource "kubernetes_namespace" "cassandra" {
  metadata { name = "cassandra" }
}

resource "helm_release" "cassandra" {
  count      = var.deploy_cassandra_aws_k8s ? 1 : 0
  name       = "cassandra"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "cassandra"
  version    = "12.3.11"
  namespace  = kubernetes_namespace.cassandra.metadata[0].name

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

  depends_on = [
    kubernetes_namespace.cassandra
  ]
}
