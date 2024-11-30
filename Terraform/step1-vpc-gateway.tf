# Data block to check if an existing internet gateway is attached to the VPC
data "aws_internet_gateway" "existing_gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [module.vpc.vpc_id]
  }
}

# Define a local value to determine if an internet gateway exists
locals {
  internet_gateway_exists = length(data.aws_internet_gateway.existing_gw.ids) > 0
}

# Output the result of internet gateway existence
output "internet_gateway_exists" {
  value = local.internet_gateway_exists
}
