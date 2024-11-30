region              = "us-west-2"
vpc_cidr            = "10.0.0.0/16"
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
cluster_name        = "stage-eks-cluster"
node_instance_type  = "t3.medium"
node_desired_capacity = 2
node_max_capacity   = 4
node_min_capacity   = 1
