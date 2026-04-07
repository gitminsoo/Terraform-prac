# 루트 상속
include "root" {
  path = find_in_parent_folders()
}

# 사용할 모듈
terraform {
  source = "../../../modules/web-cluster"
}

# vpc 레이어 의존성 선언 — terraform_remote_state 없이 outputs 참조
dependency "vpc" {
  config_path = "../vpc"
}

# vpc 출력값을 cluster 모듈 inputs으로 전달
inputs = {
  env               = "dev"
  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  instance_type     = "t3.micro"
  min_size          = 1
  max_size          = 2
}
