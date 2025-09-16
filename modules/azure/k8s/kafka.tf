resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      name = "kafka"
    }
  }

  depends_on = [kubernetes_annotations.disable_azure_default]
}

resource "random_password" "kafka" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.kafka]
}

resource "helm_release" "kafka" {
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  set = [
    {
      name  = "auth.clientPassword"
      value = random_password.kafka.result
    }
  ]

  depends_on = [
    kubernetes_namespace.kafka
  ]
}
