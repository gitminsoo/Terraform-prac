terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "KMS-VPC-STEP4" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "KMS-IGW" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags              = { Name = "KMS-PUBLIC-Azone" }
}

# 조건부: enable_nat_gateway가 true일 때만 EIP 1개 생성, false면 0개
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags   = { Name = "KMS-EIP-NATGW" }
}

# 조건부: EIP와 동일한 조건으로 NAT GW 생성
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "KMS-NATGW-Azone" }
  depends_on    = [aws_internet_gateway.main]
}

# 조건부 로컬 변수 — 환경별 설정값 분기
locals {
  instance_type    = var.environment == "prod" ? "t3.small" : "t3.micro"
  min_size         = var.environment == "prod" ? 2 : 1
  max_size         = var.environment == "prod" ? 10 : 3
  multi_az_enabled = var.environment == "prod" ? true : false
}
