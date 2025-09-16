output "vm_username" {
  description = "VM login username"
  value       = "azureuser"
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = local_file.private_key.filename
}