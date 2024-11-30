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
  internet_gateway_id     = local.internet_gateway_exists ? data.aws_internet_gateway.existing_gw.id : null
}

# Conditional creation of the internet gateway if one doesn't already exist
resource "aws_internet_gateway" "stage-gw" {
  count = local.internet_gateway_id == null ? 1 : 0

  vpc_id = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.internet_gateway_id != null ? local.internet_gateway_id : aws_internet_gateway.stage-gw[0].id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Route Table Association for subnet A
resource "aws_route_table_association" "subnet_association_a" {
  subnet_id      = module.vpc.public_subnets[0]
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for subnet B
resource "aws_route_table_association" "subnet_association_b" {
  subnet_id      = module.vpc.public_subnets[1]
  route_table_id = aws_route_table.public_rt.id
}
