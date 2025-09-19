variable "region" {
  description = "AWS region"
  default = "us-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default = "t2.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  default = "Provisioned by Terraform"
}

variable "ssh_private_key" {
  description = "Private key to connect to EC2"
  type        = string
  sensitive   = true
}
