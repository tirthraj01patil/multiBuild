# Namespace
resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

# Random password
resource "random_password" "postgres" {
  length  = 16
  special = true

  depends_on = [kubernetes_namespace.postgres]
}

# Helm release
resource "helm_release" "postgres" {
  count      = var.deploy_postgres_aws_k8s ? 1 : 0
  name       = "postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "15.3.0"
  namespace  = kubernetes_namespace.postgres.metadata[0].name

  set = [
    {
      name  = "auth.username"
      value = "postgres"
    },
    {
      name  = "auth.password"
      value = random_password.postgres.result
    },
    {
      name  = "auth.database"
      value = "postgres"
    },
    {
      name  = "primary.service.ports.postgresql"
      value = "5431"
    },
    {
      name  = "primary.persistence.size"
      value = "8Gi"
    }
  ]

  depends_on = [kubernetes_namespace.postgres]
}
