terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend는 default(local)로 유지 — 닭-달걀 문제 방지
}

provider "aws" {
  region = "ap-south-1"
}

# S3 버킷 생성 (versioning 활성화)
resource "aws_s3_bucket" "tfstate" {
  bucket        = "kms-tfstate-prac8"
  force_destroy = true   # 실습용: 비어있지 않아도 destroy 허용

  tags = { Name = "kms-tfstate-prac8" }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public access 차단
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB 테이블 (State Lock용)
resource "aws_dynamodb_table" "tflock" {
  name         = "KMS-tflock-prac8"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = { Name = "KMS-tflock-prac8" }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tflock.name
}
