terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# ★ VPC 레이어 state를 S3에서 읽어옴
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "kms-tfstate-prac8"
    key    = "dev/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "web_cluster" {
  source = "../../../modules/webcluster"

  project_name       = var.project_name
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity

  # VPC 정보는 remote_state에서 주입
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}

output "alb_dns_name" {
  value = module.web_cluster.alb_dns_name
}
