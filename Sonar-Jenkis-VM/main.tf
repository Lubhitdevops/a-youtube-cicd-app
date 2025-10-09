# main.tf

provider "aws" {
  region = var.aws_region
}

# Security Group for Jenkins, SonarQube, SSH
resource "aws_security_group" "dev_sg" {
  name        = "dev-security-group"
  description = "Allow SSH, Jenkins, and SonarQube access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-sg"
  }
}

# EC2 Instance 
resource "aws_instance" "dev_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "DevOps-Instance"
  }
}
