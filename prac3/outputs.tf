# VPC 정보
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

# 서브넷 정보
output "public_subnet_id" {
  description = "퍼블릭 서브넷 ID"
  value       = aws_subnet.public.id
}

# EC2 정보
output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "EC2 퍼블릭 IP"
  value       = aws_instance.web.public_ip
}

output "instance_type_used" {
  description = "실제 사용된 인스턴스 타입"
  value       = aws_instance.web.instance_type
}

# AMI 정보
output "ami_id" {
  description = "사용된 Ubuntu 24.04 AMI ID"
  value       = data.aws_ami.ubuntu.id
}

output "ami_name" {
  description = "사용된 AMI 이름"
  value       = data.aws_ami.ubuntu.name
}

# 태그 정보 — map 출력 예시
output "applied_tags" {
  description = "적용된 공통 태그"
  value       = var.common_tags
}
