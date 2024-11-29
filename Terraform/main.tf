provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "eks_public_subnet_1" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_1_cidr
  availability_zone = var.public_az_1
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet-1"
  }
}

resource "aws_subnet" "eks_public_subnet_2" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_2_cidr
  availability_zone = var.public_az_2
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet-2"
  }
}

# Create Private Subnets (For worker nodes)
resource "aws_subnet" "eks_private_subnet_1" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_1_cidr
  availability_zone = var.private_az_1
  tags = {
    Name = "eks-private-subnet-1"
  }
}

resource "aws_subnet" "eks_private_subnet_2" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_2_cidr
  availability_zone = var.private_az_2
  tags = {
    Name = "eks-private-subnet-2"
  }
}

# Create an Internet Gateway for Public Subnets
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-igw"
  }
}

# Create Security Group for EKS Cluster
resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  vpc_id      = aws_vpc.eks_vpc.id
  description = "Allow all inbound traffic for the EKS cluster"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Role for Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.eks_public_subnet_1.id,
      aws_subnet.eks_public_subnet_2.id,
      aws_subnet.eks_private_subnet_1.id,
      aws_subnet.eks_private_subnet_2.id
    ]
    security_group_ids = [aws_security_group.eks_security_group.id]
  }

  depends_on = [aws_internet_gateway.eks_igw]
}

# Create EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.eks_private_subnet_1.id, aws_subnet.eks_private_subnet_2.id]
  instance_types  = var.instance_types
  desired_capacity = var.node_desired_capacity
  max_capacity     = var.node_max_capacity
  min_capacity     = var.node_min_capacity

  scaling_config {
    desired_size = var.node_desired_capacity
    max_size     = var.node_max_capacity
    min_size     = var.node_min_capacity
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}
