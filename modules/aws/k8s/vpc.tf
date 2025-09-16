# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "kubernetes.io/cluster/${var.project}-${var.tags.Environment}-cluster" = "shared",
      Service                                                                = "network",
      Environment                                                            = terraform.workspace,
      Name                                                                   = "${var.project}-${var.tags.Environment}-vpc"
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      "kubernetes.io/cluster/${var.project}-${var.tags.Environment}-cluster" = "shared",
      "kubernetes.io/role/elb"                                               = 1,
      Service                                                                = "aws-sub-public",
      Environment                                                            = terraform.workspace,
      Name                                                                   = "${var.project}-${var.tags.Environment}-sub-public"
    },
    var.tags
  )

  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index + var.availability_zones_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      "kubernetes.io/cluster/${var.project}-${var.tags.Environment}-cluster" = "shared",
      "kubernetes.io/role/internal-elb"                                      = 1,
      Service                                                                = "eks-cluster-role",
      Environment                                                            = terraform.workspace,
      Name                                                                   = "${var.project}-${var.tags.Environment}-sub-private"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Service     = "igw",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-igw"
    },
    var.tags
  )

  depends_on = [aws_vpc.this]
}

# Route Table(s)
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    {
      Service     = "eks-route-table",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-route-table"
    },
    var.tags
  )
}

# Route table and subnet associations
resource "aws_route_table_association" "internet_access" {
  count = var.availability_zones_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.main.id

  depends_on = [aws_subnet.public, aws_route_table.main]
}

# NAT Elastic IP
resource "aws_eip" "main" {
  domain = "vpc"

  tags = merge(
    {
      Service     = "eip",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-eip"
    },
    var.tags
  )
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    {
      Service     = "ngw",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-ngw"
    },
    var.tags
  )
}

# Add route to route table
resource "aws_route" "main" {
  route_table_id         = aws_vpc.this.default_route_table_id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_nat_gateway.main]
}

# Security group for public subnet
resource "aws_security_group" "public_sg" {
  name   = "${var.project}-${var.tags.Environment}-public-sg"
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Service     = "public-sg",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-public-sg"
    },
    var.tags
  )
}

# Security group traffic rules
resource "aws_security_group_rule" "sg_ingress_public_443" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_public_80" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_egress_public" {
  security_group_id = aws_security_group.public_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for data plane
resource "aws_security_group" "data_plane_sg" {
  name   = "${var.project}-${var.tags.Environment}-worker-sg"
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Service     = "data_plane_sg",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-worker-sg"
    },
    var.tags
  )
}

# Security group traffic rules
resource "aws_security_group_rule" "nodes" {
  description       = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 0), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 1), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 2), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 3)])
}

resource "aws_security_group_rule" "nodes_inbound" {
  description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 2), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 3)])
}

resource "aws_security_group_rule" "node_outbound" {
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for control plane
resource "aws_security_group" "control_plane_sg" {
  name   = "${var.project}-ControlPlane-sg"
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Service     = "secuirty-eks",
      Environment = terraform.workspace,
      Name        = "${var.project}-${var.tags.Environment}-ControlPlane-sg"
    },
    var.tags
  )
}

# Security group traffic rules
resource "aws_security_group_rule" "control_plane_inbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = flatten([cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 0), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 1), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 2), cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, 3)])
  description       = "Allow HTTPS from VPC subnets to EKS API"
}

resource "aws_security_group_rule" "control_plane_outbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}