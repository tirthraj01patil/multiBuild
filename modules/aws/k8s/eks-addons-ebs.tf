# AWS EBS CSI Driver IAM Role
module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = "${var.project}-${var.tags.Environment}-ebs_csi_driver"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  depends_on = [
    helm_release.alb-controller
  ]
}

# AWS EBS CSI Driver Helm Chart
resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.27.0"

  set = [
    {
      name  = "controller.serviceAccount.create"
      value = "true"
    },
    {
      name  = "controller.serviceAccount.name"
      value = "ebs-csi-controller-sa"
    },
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.ebs_csi_irsa_role.iam_role_arn
    }
  ]

  depends_on = [
    module.ebs_csi_irsa_role,
    helm_release.alb-controller
  ]
}

resource "kubernetes_storage_class_v1" "standard_sc" {
  metadata {
    name = "standard-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type = "gp3"
  }

  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  mount_options = ["debug"]

  volume_binding_mode = "WaitForFirstConsumer"

  depends_on = [
    helm_release.ebs_csi_driver,
    module.ebs_csi_irsa_role,
    helm_release.alb-controller
  ]
}

resource "kubernetes_annotations" "disable_gp2" {
  annotations = {
    "storageclass.kubernetes.io/is-default-class" : "false"
  }

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }

  force = true

  depends_on = [
    helm_release.ebs_csi_driver,
    kubernetes_storage_class_v1.standard_sc,
    module.ebs_csi_irsa_role,
    helm_release.alb-controller
  ]
}
