resource "kubernetes_namespace" "neo4j" {
  metadata {
    name = "neo4j"
    labels = { name = "neo4j" }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

resource "random_password" "neo4j" {
  length  = 16
  special = false
  depends_on = [kubernetes_namespace.neo4j]
}

resource "helm_release" "neo4j" {
  count      = var.deploy_neo4j_gcp_k8s ? 1 : 0
  name       = "neo4j"
  namespace  = kubernetes_namespace.neo4j.metadata[0].name
  repository = "https://neo4j.github.io/helm-charts/"
  chart      = "neo4j"
  version    = "5.12.0"

  set = [
    {
      name  = "acceptLicenseAgreement"
      value = "yes"
    },
    {
      name  = "neo4j.password"
      value = random_password.neo4j.result
    },
    {
      name  = "volumes.data.mode"
      value = "persistentVolumeClaim"
    },
    {
      name  = "volumes.data.size"
      value = "10Gi"
    }
  ]

  depends_on = [kubernetes_namespace.neo4j]
}
