output "ipv4_address" {
  value = hcloud_server.server.ipv4_address
}

output "username" {
  value = "root"
}

output "ssh_private_key" {
  value = local_file.private_key.filename

}