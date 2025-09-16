resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      name = "postgres"
    }
  }

  depends_on = [kubernetes_annotations.disable_azure_default]
}

resource "random_password" "postgres" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.postgres]
}

resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.postgres.metadata[0].name

  set = [
    {
      name  = "auth.password"
      value = random_password.postgres.result
    }
  ]

  depends_on = [
    kubernetes_namespace.postgres
  ]
}
