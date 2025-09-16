resource "kubernetes_namespace" "neo4j" {
  metadata {
    name = "neo4j"
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

resource "random_password" "neo4j" {
  length  = 16
  special = true

  depends_on = [kubernetes_namespace.neo4j]
}

resource "helm_release" "neo4j" {
  count      = var.deploy_neo4j_aws_k8s ? 1 : 0
  name       = "neo4j"
  repository = "https://helm.neo4j.com/neo4j"
  chart      = "neo4j"
  version    = "5.14.0"
  namespace  = kubernetes_namespace.neo4j.metadata[0].name

  set = [
    {
      name  = "neo4j.password"
      value = random_password.neo4j.result
    },
    {
      name  = "services.neo4j.bolt.port"
      value = "7687"
    },
    {
      name  = "services.neo4j.http.port"
      value = "7474"
    },
    {
      name  = "volumes.data.size"
      value = "10Gi"
    }
  ]

  depends_on = [kubernetes_namespace.neo4j]
}
