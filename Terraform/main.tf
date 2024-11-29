provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "micro-eks-vpc"
  cidr   = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
  single_nat_gateway   = false

  private_subnets = [var.private_subnet_cidr, "10.0.2.0/24"]
  public_subnets  = [var.public_subnet_cidr, "10.0.3.0/24"]
  azs             = ["us-west-2a", "us-west-2b"]
}

resource "aws_internet_gateway" "eks-gw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "micro-eks-gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "subnet_association_a" {
  subnet_id      = module.vpc.public_subnets[0]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_association_b" {
  subnet_id      = module.vpc.public_subnets[1]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "eks_sg" {
  name        = "micro-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_eks_cluster" "micro_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }
}

resource "aws_eks_node_group" "micro_eks_node_group" {
  cluster_name    = aws_eks_cluster.micro_eks.name
  node_group_name = "micro-eks-node-group"
  node_role_arn   = aws_iam_role.eks_cluster_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_node_role_AmazonEC2ContainerRegistryReadOnly,
  ]
}
