resource "kubernetes_annotations" "disable_azure_default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "default"
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}
