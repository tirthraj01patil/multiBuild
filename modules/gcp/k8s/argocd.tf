# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd_gcp" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }

  depends_on = [kubernetes_annotations.disable_standard]
}

resource "random_password" "argocd_admin_password_gcp" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.argocd_gcp]
}

# GitHub repository credentials for ArgoCD (GCP)
resource "kubernetes_secret" "github_repository_credentials_gcp" {
  metadata {
    name      = "github-repo-credentials"
    namespace = kubernetes_namespace.argocd_gcp.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    type     = "git"
    url      = var.github_repository_url_gcp
    username = var.github_username_gcp
    password = var.github_token_gcp
  }
  depends_on = [kubernetes_namespace.argocd_gcp]
}

resource "helm_release" "argocd_gcp" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.3.0"
  namespace  = kubernetes_namespace.argocd_gcp.metadata[0].name

  set = [
    {
      name  = "server.admin.password"
      value = random_password.argocd_admin_password_gcp.result
    }
  ]

  depends_on = [
    kubernetes_namespace.argocd_gcp
  ]
}
