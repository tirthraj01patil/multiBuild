resource "kubernetes_namespace" "rabbitmq" {
  metadata {
    name = "rabbitmq"
    labels = {
      name = "rabbitmq"
    }
  }

  depends_on = [kubernetes_annotations.disable_azure_default]
}

resource "random_password" "rabbitmq" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.rabbitmq]
}

resource "helm_release" "rabbitmq" {
  name       = "rabbitmq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  namespace  = kubernetes_namespace.rabbitmq.metadata[0].name

  set = [
    {
      name  = "auth.password"
      value = random_password.rabbitmq.result
    }
  ]

  depends_on = [
    kubernetes_namespace.rabbitmq
  ]
}
