terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "KMS-VPC-STEP3" }
}

resource "aws_security_group" "web" {
  name        = "KMS-SG-WEB-STEP3"
  description = "Web SG with dynamic ingress rules"
  vpc_id      = aws_vpc.main.id

  # dynamic — ingress_rules 리스트를 순회하며 ingress 블록을 동적으로 생성
  dynamic "ingress" {
    for_each = var.ingress_rules      # 반복 대상 (iterator 기본값: ingress)
    content {                         # 각 반복에서 생성할 실제 블록 내용
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "KMS-SG-WEB-STEP3" }
}
