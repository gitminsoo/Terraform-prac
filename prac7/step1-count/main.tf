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
  tags       = { Name = "KMS-VPC-STEP1" }
}

# count — subnet_count 개수만큼 서브넷을 반복 생성
resource "aws_subnet" "private_db" {
  count = var.subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"   # 0→1, 1→2, 2→3
  availability_zone = count.index % 2 == 0 ? "ap-south-1a" : "ap-south-1c"

  tags = { Name = "KMS-PRIVATE-DB-${count.index + 1}" }
}
