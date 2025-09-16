resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
    labels = { name = "redis" }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

resource "random_password" "redis" {
  length  = 16
  special = false
  depends_on = [kubernetes_namespace.redis]
}

resource "helm_release" "redis" {
  count      = var.deploy_redis_gcp_k8s ? 1 : 0
  name       = "redis"
  namespace  = kubernetes_namespace.redis.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "18.8.2"

  set = [
    {
      name  = "auth.enabled"
      value = "true"
    },
    {
      name  = "auth.password"
      value = random_password.redis.result
    },
    {
      name  = "master.persistence.size"
      value = "5Gi"
    }
  ]

  depends_on = [kubernetes_namespace.redis]
}
