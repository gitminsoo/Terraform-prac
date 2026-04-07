terraform {
  backend "s3" {
    bucket         = "kms-tfstate-20260407"
    key            = "prac10/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "KMS-tflock-environments"
    encrypt        = true
  }
}
