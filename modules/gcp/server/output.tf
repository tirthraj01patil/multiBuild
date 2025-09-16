

# Outputs
output "server_public_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "ssh_username" {
  value = var.username_gcp
}

output "private_key_path" {
  value = local_file.private_key_pem.filename
}
