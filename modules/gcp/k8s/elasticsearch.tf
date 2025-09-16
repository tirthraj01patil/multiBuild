resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "mongoelasticsearchdb"
    labels = { name = "elasticsearch" }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

resource "helm_release" "elasticsearch" {
  count      = var.deploy_elasticsearch_gcp_k8s ? 1 : 0
  name       = "elasticsearch"
  namespace  = kubernetes_namespace.elasticsearch.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "elasticsearch"
  version    = "22.1.6"

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
      name  = "auth.enabled"
      value = "false"
    }
  ]

  depends_on = [kubernetes_namespace.elasticsearch]
}
