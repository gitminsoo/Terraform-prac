terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Remote Backend 연동 테스트용 VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "KMS-VPC-LAB05"
  }
}

# Public 서브넷
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.50.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "KMS-PUBLIC-Azone"
  }
}
