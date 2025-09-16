# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = "${var.project}-${var.tags.Environment}-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids              = flatten([aws_subnet.public[*].id, aws_subnet.private[*].id])
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Service     = "eks-cluster"
      Environment = terraform.workspace
    },
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${var.project}-${var.tags.Environment}-Cluster-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge(
    {
      Service     = "eks-cluster-role"
      Environment = terraform.workspace
    },
    var.tags
  )
}

# EKS Cluster IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project}-${var.tags.Environment}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.this.id

  tags = merge(
    {
      Service     = "eks-cluster-sg"
      Environment = terraform.workspace
    },
    var.tags
  )
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}