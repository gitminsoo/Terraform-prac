terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# vpc 모듈 호출 — modules/vpc/ 경로 참조
module "vpc" {
  source = "./modules/vpc"

  name_prefix              = var.name_prefix
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_web_subnet_cidrs = var.private_web_subnet_cidrs
  availability_zones       = var.availability_zones
  enable_nat_gateway       = var.enable_nat_gateway
}

# 두 번째 VPC를 같은 모듈로 생성 (MGMT VPC)
module "mgmt_vpc" {
  source = "./modules/vpc"

  name_prefix              = "KMS-MGMT"
  vpc_cidr                 = "10.70.0.0/16"
  public_subnet_cidrs      = ["10.70.1.0/24"]
  private_web_subnet_cidrs = ["10.70.11.0/24"]
  availability_zones       = ["ap-south-1a"]
  enable_nat_gateway       = false   # MGMT는 NAT GW 없이
}

