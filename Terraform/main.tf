provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "micro_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true  
  enable_dns_hostnames = true 

  tags = {
    Name = "micro_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.micro_vpc.id

  tags = {
    Name = "micro_internet_gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.micro_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.micro_vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.micro_vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = "us-west-2b"

  tags = {
    Name = "public_subnet_b"
  }
}

resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "allow_ssh_http" {
  vpc_id      = aws_vpc.micro_vpc.id
  name        = "allow_ssh_http"
  description = "Allow SSH, HTTP, and Postgres access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
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
    Name = "allow_ssh_http"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"  # Specify a specific version
  cluster_name    = "microservice-eks"
  cluster_version = "1.17"

  vpc_id     = aws_vpc.micro_vpc.id
 # subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
      subnets = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    }
  }
}