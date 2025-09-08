output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ubuntu.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.ubuntu_eip.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ubuntu.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ubuntu.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ubuntu_sg.id
}

output "key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.ubuntu_key.key_name
}

output "private_key_file" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_eip.ubuntu_eip.public_ip}"
}
