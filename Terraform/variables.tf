variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "stage-eks-cluster"
}

variable "desired_capacity" {
  description = "The desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "The minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

variable "node_instance_type" {
  description = "The EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium"
}
