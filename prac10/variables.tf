variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "배포 환경"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment는 dev, staging, prod 중 하나여야 합니다."
  }
}

variable "project" {
  description = "프로젝트 이니셜 (네이밍 접두사)"
  type        = string
  default     = "KMS"
}
