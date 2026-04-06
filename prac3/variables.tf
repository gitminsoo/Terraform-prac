# 문자열 타입 — 환경 구분자
variable "environment" {
  type        = string
  description = "배포 환경 (dev / staging / prod)"
  default     = "dev"
}

# 문자열 타입 — AWS 리전
variable "aws_region" {
  type        = string
  description = "AWS 배포 리전"
  default     = "ap-northeast-2"
}

# 문자열 타입 — EC2 인스턴스 타입
variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 타입"
  default     = "t3.micro"
}

# 숫자 타입 — 루트 볼륨 크기(GB)
variable "root_volume_size" {
  type        = number
  description = "루트 EBS 볼륨 크기 (GB)"
  default     = 20
}

# 불리언 타입 — 퍼블릭 IP 자동 할당 여부
variable "enable_public_ip" {
  type        = bool
  description = "퍼블릭 IP 자동 할당 여부"
  default     = true
}

# 리스트 타입 — 허용 포트 목록
variable "allowed_ports" {
  type        = list(number)
  description = "Security Group에서 허용할 포트 목록"
  default     = [22, 80, 443]
}

# 맵 타입 — 공통 태그
variable "common_tags" {
  type        = map(string)
  description = "모든 리소스에 공통 적용할 태그"
  default = {
    Project   = "KMS-LAB"
    ManagedBy = "Terraform"
    Owner     = "KMS"
  }
}

# 문자열 타입 — VPC CIDR
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
  default     = "10.0.0.0/16"
}

# 문자열 타입 — 퍼블릭 서브넷 CIDR
variable "public_subnet_cidr" {
  type        = string
  description = "퍼블릭 서브넷 CIDR"
  default     = "10.0.1.0/24"
}