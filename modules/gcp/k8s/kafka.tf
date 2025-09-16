resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
    labels = { name = "kafka" }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

resource "random_password" "kafka" {
  length  = 16
  special = false
  depends_on = [kubernetes_namespace.kafka]
}

resource "helm_release" "kafka" {
  count      = var.deploy_kafka_gcp_k8s ? 1 : 0
  name       = "kafka"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "32.4.3"

  set = [
    {
      name  = "replicaCount"
      value = "1"
    },
    {
      name  = "auth.clientProtocol"
      value = "sasl"
    },
    {
      name  = "auth.sasl.enabledMechanisms"
      value = "PLAIN"
    },
    {
      name  = "auth.sasl.interBrokerMechanism"
      value = "PLAIN"
    },
    {
      name  = "auth.jaas.clientUsers"
      value = "kafka"
    },
    {
      name  = "auth.jaas.clientPasswords"
      value = random_password.kafka.result
    },
    {
      name  = "auth.jaas.interBrokerUser"
      value = "kafka"
    },
    {
      name  = "auth.jaas.interBrokerPassword"
      value = random_password.kafka.result
    },
    {
      name  = "persistence.size"
      value = "10Gi"
    }
  ]

  depends_on = [kubernetes_namespace.kafka]
}
