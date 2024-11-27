output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.micro_vpc.id
}


output "kubeconfig" {
  value = module.eks.kubeconfig
}

