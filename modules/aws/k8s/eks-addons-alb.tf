provider "kubernetes" {
  host                   = data.aws_eks_cluster.existing.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.existing.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.existing.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.existing.token
  }
}

data "aws_eks_cluster" "existing" {
  name = "${var.project}-${var.tags.Environment}-cluster"

  depends_on = [aws_eks_node_group.this]
}

data "aws_eks_cluster_auth" "existing" {
  name = data.aws_eks_cluster.existing.name

  depends_on = [aws_eks_node_group.this]
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.existing.identity[0].oidc[0].issuer

  depends_on = [aws_eks_node_group.this]
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.existing.identity[0].oidc[0].issuer
}

# AWS Load Balancer Controller IAM Role
module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name                              = "${var.project}-${var.tags.Environment}-eks-lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  depends_on = [aws_eks_node_group.this]
}

# Kubernetes Service Account for Load Balancer Controller
resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }

  depends_on = [
    aws_iam_openid_connect_provider.eks,
    aws_eks_node_group.this
  ]
}

# Helm Release for AWS Load Balancer Controller
resource "helm_release" "alb-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set = [
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "clusterName"
      value = data.aws_eks_cluster.existing.name
    }
  ]

  depends_on = [
    kubernetes_service_account.service-account,
    aws_eks_node_group.this
  ]
}

# # IAM Role for Cluster Autoscaler
# module "autoscaler_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.30.0"

#   role_name                        = "${var.project}-${var.tags.Environment}-eks-autoscaler"
#   attach_cluster_autoscaler_policy = true
#   cluster_autoscaler_cluster_names = [data.aws_eks_cluster.existing.name]

#   oidc_providers = {
#     main = {
#       provider_arn               = aws_iam_openid_connect_provider.eks.arn
#       namespace_service_accounts = ["kube-system:cluster-autoscaler"]
#     }
#   }
# }

# # Kubernetes Service Account for Cluster Autoscaler
# resource "kubernetes_service_account" "autoscaler" {
#   metadata {
#     name      = "cluster-autoscaler"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn"               = module.autoscaler_role.iam_role_arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }

#   depends_on = [
#     aws_iam_openid_connect_provider.eks,
#     aws_eks_node_group.this
#   ]
# }

# # Helm Release for Cluster Autoscaler
# resource "helm_release" "autoscaler" {
#   name       = "${var.project}-${var.tags.Environment}-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"

#   set = [
#     {
#       name  = "autoDiscovery.clusterName"
#       value = data.aws_eks_cluster.existing.name
#     },
#     {
#       name  = "rbac.serviceAccount.create"
#       value = "false"
#     },
#     {
#       name  = "rbac.serviceAccount.name"
#       value = "cluster-autoscaler"
#     }
#   ]

#   depends_on = [
#     kubernetes_service_account.autoscaler
#   ]
# }

# # Helm Release for Metrics Server
# resource "helm_release" "metrics_server" {
#   name       = "${var.project}-${var.tags.Environment}-metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"

#   set = [
#     {
#       name  = "args[0]"
#       value = "--kubelet-insecure-tls"
#     }
#   ]
# }
