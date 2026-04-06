# S3 버킷 + DynamoDB 테이블 부트스트랩 (로컬 state로 관리)
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

# tfstate를 저장할 S3 버킷
resource "aws_s3_bucket" "tfstate" {
  bucket = "kms-tfstate-lab05"
  force_destroy = true

  tags = {
    Name = "kms-tfstate-lab05"
  }
}

# S3 버전 관리 활성화 (state 히스토리 보존)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 서버 사이드 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# State 잠금용 DynamoDB 테이블
resource "aws_dynamodb_table" "tflock" {
  name         = "KMS-tflock-lab05"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "KMS-tflock-lab05"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tflock.name
}
