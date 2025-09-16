resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
    labels = {
      name = "redis"
    }
  }

  depends_on = [kubernetes_annotations.disable_azure_default]
}

resource "random_password" "redis" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.redis]
}

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  namespace  = kubernetes_namespace.redis.metadata[0].name

  set = [
    {
      name  = "auth.password"
      value = random_password.redis.result
    }
  ]

  depends_on = [
    kubernetes_namespace.redis
  ]
}
