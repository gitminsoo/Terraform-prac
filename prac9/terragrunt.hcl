# 로컬 변수: 경로에서 환경명(dev/staging/prod) 자동 추출

locals {
    env = element(split("/", path_relative_to_include()), 0)
}

# Remote State 자동 설정 — S3 버킷/DynamoDB 테이블을 자동 생성
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "kms-tfstate-${local.env}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "KMS-tflock-${local.env}"
  }
}

# Provider 설정 자동 생성 — 각 모듈에 provider.tf를 자동 주입
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "ap-south-1"
}
EOF
}
