
# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private Key
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.instance_name}.pem"
  file_permission = "0600"
}

# Provisioning Script
locals {
  gcp_user_data = templatefile("${path.module}/user-data.sh", {
    deploy_postgres = tostring(var.deploy_postgres_gcp)
    deploy_redis    = tostring(var.deploy_redis_gcp)
    deploy_kafka    = tostring(var.deploy_kafka_gcp)
    deploy_rabbitmq = tostring(var.deploy_rabbitmq_gcp)
    deploy_neo4j    = tostring(var.deploy_neo4j_gcp)
  })
}

# GCP Compute Instance
resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {} # Enables public IPv4
  }

  metadata = {
    ssh-keys = "${var.username_gcp}:${tls_private_key.ssh_key.public_key_openssh}"
  }

  metadata_startup_script = local.gcp_user_data
}

