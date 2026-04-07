# modules/web-cluster/variables.tf

# --- VPC 참조 변수 (remote_state에서 주입) ---
variable "vpc_id" {
  description = "배포 대상 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB가 위치할 퍼블릭 서브넷 ID 목록"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "ASG 인스턴스가 위치할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}

# --- 클러스터 설정 변수 ---
variable "project_name" {
  description = "프로젝트 이니셜"
  type        = string
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
  default     = 3
}

variable "desired_capacity" {
  description = "ASG 희망 인스턴스 수"
  type        = number
  default     = 2
}
