# Generate SSH key pair
resource "aws_key_pair" "ubuntu_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ubuntu_key.public_key_openssh

  tags = {
    Name = var.key_name
  }
}

# Generate private key for SSH access
resource "tls_private_key" "ubuntu_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file
resource "local_file" "private_key" {
  content         = tls_private_key.ubuntu_key.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

# Security group for the EC2 instance
resource "aws_security_group" "ubuntu_sg" {
  name        = var.security_group_name
  description = "Security group for Ubuntu EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access from allowed CIDR blocks
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTP access from allowed CIDR blocks
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTPS access from allowed CIDR blocks
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# EC2 instance
resource "aws_instance" "ubuntu" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.ubuntu_key.key_name
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]
  subnet_id             = var.subnet_id

  # Enable detailed monitoring
  monitoring = true

  # Root block device
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    
    tags = {
      Name = "${var.instance_name}-root"
    }
  }

  # User data script for initial setup
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
    
    # Install basic packages
    apt-get install -y curl wget git htop tree unzip
    
    # Configure automatic security updates
    apt-get install -y unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
    
    # Create a welcome message
    echo "Welcome to Ubuntu EC2 Instance" > /etc/motd
    echo "Instance created by Terraform" >> /etc/motd
    echo "SSH key: ${var.key_name}" >> /etc/motd
    
    # Log completion
    echo "$(date): User data script completed" >> /var/log/user-data.log
  EOF
  )

  tags = {
    Name = var.instance_name
  }
}

# Elastic IP for the instance
resource "aws_eip" "ubuntu_eip" {
  instance = aws_instance.ubuntu.id
  domain   = "vpc"

  tags = {
    Name = "${var.instance_name}-eip"
  }

  depends_on = [aws_instance.ubuntu]
}
