provider "aws" {
  region = "ap-south-1"
}

module "web_cluster" {
  source = "../../modules/web-cluster"

  env              = var.env
  vpc_cidr         = var.vpc_cidr
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
}
