resource "kubernetes_namespace" "neo4j" {
  metadata {
    name = "neo4j"
    labels = {
      name = "neo4j"
    }
  }

  depends_on = [kubernetes_annotations.disable_azure_default]
}

resource "random_password" "neo4j" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.neo4j]
}

resource "helm_release" "neo4j" {
  name       = "neo4j"
  repository = "https://neo4j.github.io/helm-charts"
  chart      = "neo4j"
  namespace  = kubernetes_namespace.neo4j.metadata[0].name

  set = [
    {
      name  = "neo4j.password"
      value = random_password.neo4j.result
    }
  ]

  depends_on = [
    kubernetes_namespace.neo4j
  ]
}
