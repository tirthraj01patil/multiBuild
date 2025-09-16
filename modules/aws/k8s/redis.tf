resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

resource "random_password" "redis" {
  length  = 16
  special = true

  depends_on = [kubernetes_namespace.redis]
}

resource "helm_release" "redis" {
  count      = var.deploy_redis_aws_k8s ? 1 : 0
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "17.5.0"
  namespace  = kubernetes_namespace.redis.metadata[0].name

  set = [
    {
      name  = "auth.password"
      value = random_password.redis.result
    },
    {
      name  = "master.persistence.size"
      value = "8Gi"
    },
    {
      name  = "replica.replicaCount"
      value = "1"
    }
  ]

  depends_on = [kubernetes_namespace.redis]
}
