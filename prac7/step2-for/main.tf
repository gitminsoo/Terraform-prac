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
  tags       = { Name = "KMS-VPC-STEP2" }
}

# for_each — 맵의 각 항목(key=이름, value=CIDR)을 순회하여 서브넷 생성
resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
# A존 이름이 포함된 서브넷은 ap-south-1a, 그렇지 않으면 ap-south-1c 할당
# regex 함수로 이름에 "Azone"이 포함되어 있는지 확인하여 가용 영역 결정
# regex는 에러 발생 가능
# can 함수로 regex 실행 가능 여부 확인 후 조건문으로 가용 영역 할당
  availability_zone = can(regex("Azone", each.key)) ? "ap-south-1a" : "ap-south-1c"

  tags = { Name = each.key }
}
