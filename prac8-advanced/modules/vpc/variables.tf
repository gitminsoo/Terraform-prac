variable "project_name" {
  description = "프로젝트 이니셜 (네이밍 prefix)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록 (AZ 순서대로)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 목록 (AZ 순서대로)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "azs" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1c"]
}

variable "enable_nat_gateway" {
  description = "NAT Gateway 생성 여부"
  type        = bool
  default     = true
}
