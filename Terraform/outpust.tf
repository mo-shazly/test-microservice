output "eks_cluster_name" {
  value = aws_eks_cluster.example.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
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

output "eks_nodegroup_arn" {
  value = aws_eks_node_group.example.arn
}