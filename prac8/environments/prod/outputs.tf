output "alb_dns_name" {
  description = "[prod] ALB 접속 주소"
  value       = module.web_cluster.alb_dns_name
}

output "vpc_id" {
  description = "[prod] 생성된 VPC ID"
  value       = module.web_cluster.vpc_id
}
