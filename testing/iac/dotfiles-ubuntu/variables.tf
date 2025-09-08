variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "bh-fred-sandbox"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the instance"
  type        = list(string)
  default     = ["24.181.4.123/32"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name for the SSH key pair"
  type        = string
  default     = "dotfiles-ubuntu-key"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "dotfiles-ubuntu-instance"
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "dotfiles-ubuntu-sg"
}
