include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/web-cluster"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  env                = "staging"
  vpc_id             = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  instance_type      = "t3.small"
  min_size           = 2
  max_size           = 4
}
