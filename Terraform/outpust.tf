output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_kubeconfig" {
  value = aws_eks_cluster.eks_cluster.kubeconfig
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}
