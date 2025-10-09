variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance type"
  default     = "t2.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "realtime-project"
}

variable "ubuntu_ami" {
  description = "Ubuntu 24.04 LTS AMI in us-east-1"
  default     = "ami-0885b1f6bd170450c" # Update if needed
}

variable "volume_size" {
  description = "Root volume size in GB"
  default     = 23
}
