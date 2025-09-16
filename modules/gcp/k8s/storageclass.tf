resource "kubernetes_annotations" "disable_standard" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "standard"
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}
