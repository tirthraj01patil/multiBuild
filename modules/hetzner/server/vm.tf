# Force new SSH key creation every apply
resource "null_resource" "force_new_key" {
  triggers = {
    always_new = timestamp()
  }
}

# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm  = "RSA"
  rsa_bits   = 4096
  depends_on = [null_resource.force_new_key]
}

# Save private key to file
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.server_name}-${timestamp()}.pem"
  file_permission = "0600"
}

# Upload Public Key to Hetzner (unique name each time)
resource "hcloud_ssh_key" "default" {
  name       = "terraform-key-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# User Data Template
locals {
  hetzner_user_data = templatefile("${path.module}/user-data.sh", {
    deploy_postgres = tostring(var.deploy_postgres_hetzner)
    deploy_redis    = tostring(var.deploy_redis_hetzner)
    deploy_kafka    = tostring(var.deploy_kafka_hetzner)
    deploy_rabbitmq = tostring(var.deploy_rabbitmq_hetzner)
    deploy_neo4j    = tostring(var.deploy_neo4j_hetzner)
  })
}

# Create Hetzner Server
resource "hcloud_server" "server" {
  name        = var.server_name
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.name]
  user_data   = local.hetzner_user_data
}
