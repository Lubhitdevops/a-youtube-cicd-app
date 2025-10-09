# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS (Free-tier) AMI ID for us-east-1"
  type        = string
  default     = "ami-04b70fa74e45c3917"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
  default     = "realtime-project"
}

variable "volume_size" {
  description = "Root volume size (GB)"
  type        = number
  default     = 25
}
