resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      name = "elasticsearch"
    }
  }

  depends_on = [kubernetes_annotations.disable_azure_default]
}

resource "random_password" "elasticsearch" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.elasticsearch]
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = kubernetes_namespace.elasticsearch.metadata[0].name

  set = [
    {
      name  = "secret.password"
      value = random_password.elasticsearch.result
    }
  ]

  depends_on = [
    kubernetes_namespace.elasticsearch
  ]
}
