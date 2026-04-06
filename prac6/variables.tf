variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-south-1"
}

variable "name_prefix" {
  description = "리소스 네이밍 이니셜"
  type        = string
  default     = "KMS"
}

variable "vpc_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.60.1.0/24", "10.60.2.0/24"]
}

variable "private_web_subnet_cidrs" {
  type    = list(string)
  default = ["10.60.11.0/24", "10.60.12.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1c"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}
