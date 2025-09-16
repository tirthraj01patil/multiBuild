resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

resource "random_password" "kafka" {
  length  = 16
  special = true

  depends_on = [kubernetes_namespace.kafka]
}

resource "helm_release" "kafka" {
  count      = var.deploy_kafka_aws_k8s ? 1 : 0
  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "32.4.3"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  set = [
    {
      name  = "auth.clientProtocol"
      value = "sasl"
    },
    {
      name  = "auth.interBrokerProtocol"
      value = "sasl"
    },
    {
      name  = "auth.saslMechanisms"
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
      name  = "service.ports.client"
      value = "9092"
    },
    {
      name  = "service.ports.controller"
      value = "9093"
    }
  ]

  depends_on = [kubernetes_namespace.kafka]
}
