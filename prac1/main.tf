# Provider 설정 — AWS 서울 리전 사용
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

# EC2 인스턴스 — KMS 네이밍 적용
resource "aws_instance" "kms_ec2_lab01" {
  ami           = "ami-07216ac99dc46a187"
  instance_type = "t3.micro"

  tags = {
    Name = "KMS-EC2-LAB01"
  }
}
