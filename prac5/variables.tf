variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.50.0.0/16"
}
