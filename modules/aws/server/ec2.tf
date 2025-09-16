# Get latest Ubuntu 22.04 LTS AMI for the region
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.mykey.private_key_pem
  filename        = "${path.module}/${var.project_name_server}.pem"
  file_permission = "0600"
}

resource "random_id" "key_id" {
  byte_length = 4
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.project_name_server}-${random_id.key_id.hex}"
  public_key = tls_private_key.mykey.public_key_openssh
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name_server}-vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name_server}-subnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name_server}-igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "main_sg" {
  name        = "${var.project_name_server}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL"
    from_port   = 5431
    to_port     = 5431
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kafka"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RabbitMQ"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Neo4j"
    from_port   = 7474
    to_port     = 7474
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name_server}-sg"
  }
}

# Create user data script as a template file for better debugging
locals {
  user_data = templatefile("${path.module}/user-data.sh", {
    deploy_postgres = tostring(var.deploy_postgres_aws)
    deploy_redis    = tostring(var.deploy_redis_aws)
    deploy_kafka    = tostring(var.deploy_kafka_aws)
    deploy_rabbitmq = tostring(var.deploy_rabbitmq_aws)
    deploy_neo4j    = tostring(var.deploy_neo4j_aws)
  })
}


resource "aws_instance" "ubuntu_server" {
  ami                         = data.aws_ami.ubuntu_latest.id
  instance_type               = var.instance_type_server
  subnet_id                   = aws_subnet.main_subnet.id
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.user_data)

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name_server}-server"
  }

  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table_association.rta
  ]
}

