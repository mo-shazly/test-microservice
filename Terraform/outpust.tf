output "eks_cluster_name" {
  value = aws_eks_cluster.stage_eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.stage_eks.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.stage_eks.certificate_authority[0].data
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
  value = aws_eks_node_group.stage_eks_node_group.arn
}

output "internet_gateway_id" {
  value       = local.internet_gateway_id != null ? local.internet_gateway_id : aws_internet_gateway.stage-gw[0].id
  description = "The ID of the Internet Gateway, if any exists."
}
