# 루트 terragrunt.hcl 상속 (remote_state + provider 자동 설정)
include "root" {
  path = find_in_parent_folders()
}

# 사용할 Terraform 모듈 경로 지정
terraform {
  source = "../../../modules/vpc"
}

# 모듈에 전달할 입력값
inputs = {
  env                  = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}
