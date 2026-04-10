variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "ubuntu_ami" {
  description = "Ubuntu 24.04 LTS AMI for ap-south-1"
  default     = "ami-0f58b397bc5c1f2e8"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Your AWS key pair name"
  default     = "infrawatch-key"
}
