variable "env" {
  description = "배포 환경 이름 (dev / staging / prod)"
  type        = string
}


variable "vpc_cidr" {
  description = "VPC CIDR 블록 (환경별 대역 분리)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "ASG 최소 인스턴스 수"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "ASG 최대 인스턴스 수"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "ASG 희망 인스턴스 수"
  type        = number
  default     = 1
}

variable "ami_id" {
    description = "EC2 인스턴스에 사용할 AMI ID"
    type        = string
    default = "ami-07216ac99dc46a187"
    # 우분투 22.04 LTS (HVM)
}