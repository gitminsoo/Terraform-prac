terraform {
  backend "s3" {
    bucket         = "kms-tfstate-prac8"          # Part 5에서 생성한 버킷
    key            = "dev/vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "KMS-tflock-prac8"
    encrypt        = true
  }
}
