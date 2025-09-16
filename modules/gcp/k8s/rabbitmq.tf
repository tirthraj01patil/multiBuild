resource "kubernetes_namespace" "rabbitmq" {
  metadata {
    name = "rabbitmq"
    labels = { name = "rabbitmq" }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

resource "random_password" "rabbitmq" {
  length  = 16
  special = false
  depends_on = [kubernetes_namespace.rabbitmq]
}

resource "helm_release" "rabbitmq" {
  count      = var.deploy_rabbitmq_gcp_k8s ? 1 : 0
  name       = "rabbitmq"
  namespace  = kubernetes_namespace.rabbitmq.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "12.1.7"

  set = [
    {
      name  = "auth.username"
      value = "admin"
    },
    {
      name  = "auth.password"
      value = random_password.rabbitmq.result
    },
    {
      name  = "persistence.size"
      value = "5Gi"
    }
  ]

  depends_on = [kubernetes_namespace.rabbitmq]
}
