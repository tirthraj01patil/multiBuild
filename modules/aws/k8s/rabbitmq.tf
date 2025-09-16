resource "kubernetes_namespace" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

resource "random_password" "rabbitmq" {
  length  = 16
  special = true

  depends_on = [kubernetes_namespace.rabbitmq]
}

resource "helm_release" "rabbitmq" {
  count      = var.deploy_rabbitmq_aws_k8s ? 1 : 0
  name       = "rabbitmq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "16.0.14"
  namespace  = kubernetes_namespace.rabbitmq.metadata[0].name

  set = [
    {
      name  = "auth.username"
      value = "user"
    },
    {
      name  = "auth.password"
      value = random_password.rabbitmq.result
    },
    {
      name  = "auth.vhost"
      value = "/"
    },
    {
      name  = "service.port"
      value = "5672"
    },
    {
      name  = "persistence.size"
      value = "8Gi"
    }
  ]

  depends_on = [kubernetes_namespace.rabbitmq]
}
