terraform {
  backend "s3" {
    bucket         = "kms-tfstate-prac8"
    key            = "dev/cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "KMS-tflock-prac8"
    encrypt        = true
  }
}
