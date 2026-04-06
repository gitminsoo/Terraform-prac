provider "aws" {
  region = "ap-south-1"
}

# 공통 웹 클러스터 모듈 호출
module "web_cluster" {
  source = "../../modules/web-cluster"

  env              = var.env
  vpc_cidr         = var.vpc_cidr # [수정] vpc_id/subnet_ids 대신 vpc_cidr만 전달
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
}
