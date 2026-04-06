# S3 Remote Backend — state를 S3에 저장하고 DynamoDB로 잠금
terraform {
  backend "s3" {
    bucket         = "kms-tfstate-lab05"
    key            = "prac5/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "KMS-tflock-lab05"
    encrypt        = true
  }
}
