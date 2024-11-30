# terraform.tfvars
region               = "us-west-2"
ssh_key_name         = "my-ssh-key"
vpc_cidr             = "10.0.0.0/16"
private_subnet_cidr  = "10.0.1.0/24"
public_subnet_cidr   = "10.0.0.0/24"
cluster_name         = "stage-eks-cluster"
node_group_name      = "stage-eks-node-group"
node_instance_type   = "t3.medium"
desired_capacity     = 2
max_capacity         = 3
min_capacity         = 1
