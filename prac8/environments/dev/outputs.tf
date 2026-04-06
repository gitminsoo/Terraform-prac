output "alb_dns_name" {
  description = "[dev] ALB 접속 주소"
  value       = module.web_cluster.alb_dns_name
}

# [수정] VPC ID 출력 추가 (모듈이 생성한 VPC 확인용)
output "vpc_id" {
  description = "[dev] 생성된 VPC ID"
  value       = module.web_cluster.vpc_id
}
