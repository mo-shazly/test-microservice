output "eks_cluster_name" {
  value = aws_eks_cluster.stage_eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.stage_eks.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.stage_eks.certificate_authority[0].data
}

output "v[_{{{CITATION{{{_1{](https://github.com/praveenjirra/deploy-docker-swarm-using-terraform-ansible/tree/e051f433f9c3d73c12698a6742dce8ae19bbb07a/README.md)