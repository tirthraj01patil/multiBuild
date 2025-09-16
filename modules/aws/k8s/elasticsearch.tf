resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

resource "random_password" "elasticsearch" {
  length  = 16
  special = true

  depends_on = [kubernetes_namespace.elasticsearch]
}

resource "helm_release" "elasticsearch" {
  count      = var.deploy_elasticsearch_aws_k8s ? 1 : 0
  name       = "elasticsearch"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  version    = "22.1.6"
  namespace  = kubernetes_namespace.elasticsearch.metadata[0].name

  set = [
    {
      name  = "replicaCount"
      value = "1"
    },
    {
      name  = "volumeClaimTemplate.resources.requests.storage"
      value = "10Gi"
    },
    {
      name  = "esJavaOpts"
      value = "-Xmx512m -Xms512m"
    }
  ]

  depends_on = [kubernetes_namespace.elasticsearch]
}
