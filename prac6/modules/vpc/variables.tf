variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록 (AZ 순서대로)"
  type        = list(string)
}

variable "private_web_subnet_cidrs" {
  description = "프라이빗 웹 서브넷 CIDR 목록"
  type        = list(string)
}

variable "availability_zones" {
  description = "사용할 AZ 목록"
  type        = list(string)
}

variable "name_prefix" {
  description = "리소스 네이밍 이니셜 (예: KMS)"
  type        = string
  default     = "KMS"
}

variable "enable_nat_gateway" {
  description = "NAT Gateway 생성 여부"
  type        = bool
  default     = true
}
