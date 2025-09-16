output "instance_public_ip" {
  value = aws_instance.ubuntu_server.public_ip
}

output "private_key_file" {
  value = "${path.module}/ec2-server-key.pem"
}

output "username" {
  value = "ubuntu"
}