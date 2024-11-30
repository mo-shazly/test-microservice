# vpc-gateway.tf
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "stage-eks-vpc"
  cidr   = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
  single_nat_gateway   = false

  private_subnets = [var.private_subnet_cidr, "10.0.2.0/24"]
  public_subnets  = [var.public_subnet_cidr, "10.0.3.0/24"]
  azs             = ["us-west-2a", "us-west-2b"]
}

# Data block to check if an existing internet gateway is attached to the VPC
data "aws_internet_gateway" "existing_gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [module.vpc.vpc_id]
  }
}

# Define a local value to determine if an internet gateway exists
locals {
  internet_gateway_exists = length(data.aws_internet_gateway.existing_gw.id) > 0
}

# Output to use in Step 2
output "internet_gateway_exists" {
  value = local.internet_gateway_exists
}

output "existing_internet_gateway_id" {
  value = data.aws_internet_gateway.existing_gw.id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}
