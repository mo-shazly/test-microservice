variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  default     = "10.0.4.0/24"
}

variable "public_az_1" {
  description = "Availability Zone for the first public subnet"
  default     = "us-west-2a"
}

variable "public_az_2" {
  description = "Availability Zone for the second public subnet"
  default     = "us-west-2b"
}

variable "private_az_1" {
  description = "Availability Zone for the first private subnet"
  default     = "us-west-2a"
}

variable "private_az_2" {
  description = "Availability Zone for the second private subnet"
  default     = "us-west-2b"
}

variable "instance_types" {
  description = "EC2 instance types for the worker nodes"
  default     = ["t3.medium"]
}

variable "node_desired_capacity" {
  description = "The desired number of worker nodes"
  default     = 2
}

variable "node_max_capacity" {
  description = "The maximum number of worker nodes"
  default     = 3
}

variable "node_min_capacity" {
  description = "The minimum number of worker nodes"
  default     = 1
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "eks-cluster"
}
