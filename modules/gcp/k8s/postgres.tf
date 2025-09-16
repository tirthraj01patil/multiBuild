# Create namespace
resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      name = "postgres"
    }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

# Random password
resource "random_password" "postgres" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.postgres]
}

# Helm release
resource "helm_release" "postgres" {
  count      = var.deploy_postgres_gcp_k8s ? 1 : 0
  name       = "postgres"
  namespace  = kubernetes_namespace.postgres.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "15.5.21"

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
      name  = "primary.persistence.size"
      value = "10Gi"
    }
  ]

  depends_on = [kubernetes_namespace.postgres]
}
