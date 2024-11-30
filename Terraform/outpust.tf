output "eks_cluster_name" {
  value = aws_eks_cluster.stage_eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.stage_eks.endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}
