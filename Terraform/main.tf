terraform {
  backend "s3" {
    bucket         = "stagebucket12"
    key            = "stage-eks/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"   # Reference the DynamoDB table you just created
    encrypt        = true
  }
}


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


# Conditional creation of the internet gateway if one doesn't already exist
resource "aws_internet_gateway" "stage-gw" {
  count = length(data.aws_internet_gateway.existing_gw.ids) == 0 ? 1 : 0

  vpc_id = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

# Output the internet gateway ID if created
output "internet_gateway_id" {
  value       = length(data.aws_internet_gateway.existing_gw.ids) == 0 ? null : data.aws_internet_gateway.existing_gw.ids[0]
  description = "The ID of the Internet Gateway, if any exists."
}



# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stage-gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route_table_association" "subnet_association_a" {
  count            = length(data.aws_route_table_association.existing_association_a.id) == 0 ? 1 : 0
  subnet_id        = module.vpc.public_subnets[0]
  route_table_id   = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_association_b" {
  subnet_id        = module.vpc.public_subnets[1]
  route_table_id   = aws_route_table.public_rt.id
}


resource "aws_security_group" "eks_sg" {
  name        = "stage-eks-sg"
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

resource "aws_iam_role" "eks_worker_node_role" {
  name = "stage-eks-worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "stage-eks-cluster-role"

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

resource "aws_iam_role_policy_attachment" "eks_worker_node_role_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_worker_node_role.name  # Reference to the IAM role created for the worker nodes
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"  # Amazon EKS worker node policy
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_role_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_role_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_cluster" "stage_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }
}

resource "aws_eks_node_group" "stage_eks_node_group" {
  cluster_name    = aws_eks_cluster.stage_eks.name
  node_group_name = "stage-eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn
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
