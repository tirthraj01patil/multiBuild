# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd_aws" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }

  depends_on = [kubernetes_annotations.disable_gp2]
}

resource "random_password" "argocd_admin_password_aws" {
  length  = 16
  special = false

  depends_on = [kubernetes_namespace.argocd_aws]
}

# GitHub repository credentials for ArgoCD (AWS)
resource "kubernetes_secret" "github_repository_credentials_aws" {
  metadata {
    name      = "github-repo-credentials"
    namespace = kubernetes_namespace.argocd_aws.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    type     = "git"
    url      = var.github_repository_url_aws
    username = var.github_username_aws
    password = var.github_token_aws
  }
  depends_on = [kubernetes_namespace.argocd_aws]
}

resource "helm_release" "argocd_aws" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.3.0"
  namespace  = kubernetes_namespace.argocd_aws.metadata[0].name

  set = [
    {
      name  = "server.admin.password"
      value = random_password.argocd_admin_password_aws.result
    }
  ]

  depends_on = [
    kubernetes_namespace.argocd_aws
  ]
}
