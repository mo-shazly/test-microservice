terraform {
  backend "s3" {
    bucket         = "stagebucket12"
    key            = "stage-eks5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "stage-eks-vpc1"
  cidr   = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
  single_nat_gateway   = false

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  azs             = ["us-west-2a", "us-west-2b"]

  public_subnet_tags = {
    "kubernetes.io/role/elb"           = "1"
    "map_public_ip_on_launch"          = "true"  # Ensures instances in public subnets get public IPs
    "kubernetes.io/role/internal-elb"  = "0"
  }

  # Add this to ensure public IPs are automatically assigned
  enable_public_ip_on_launch = true  # Ensures auto-assign public IPs to instances in public subnets
}

resource "aws_security_group" "eks_sg" {
  name        = "stage-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this to your IP for security
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_key_pair" "ssh_key" {
  key_name   = "eks_ssh_key"
  public_key = file(var.public_key_path) # Specify the relative path to the key in your repo
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

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_cni_policy" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_read_only_policy" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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

resource "aws_eks_cluster" "stage_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_eks_node_group" "stage_eks_node_group" {
  cluster_name    = aws_eks_cluster.stage_eks.name
  node_group_name = "stage-eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = var.node_desired_capacity
    max_size     = var.node_max_capacity
    min_size     = var.node_min_capacity
  }

  instance_types = ["t3.medium"] # Adjust instance type as needed

  remote_access {
    ec2_ssh_key = aws_key_pair.ssh_key.key_name
  }

  depends_on = [
    aws_iam_role.eks_worker_node_role,
  ]
}
