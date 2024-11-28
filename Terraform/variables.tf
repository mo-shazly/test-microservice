variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "The CIDR block for the public subnet in availability zone A"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "The CIDR block for the public subnet in availability zone B"
  type        = string
}
