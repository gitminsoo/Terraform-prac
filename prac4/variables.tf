variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 목록 (AZ-a, AZ-c)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 목록 (AZ-a, AZ-c)"
  type        = list(string)
  default     = ["10.0.110.0/24", "10.0.120.0/24"]
}

variable "availability_zones" {
  description = "사용할 가용 영역"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1c"]
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "ASG 최소 인스턴스 수"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "ASG 최대 인스턴스 수"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "ASG 희망 인스턴스 수"
  type        = number
  default     = 2
}
