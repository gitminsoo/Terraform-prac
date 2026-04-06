output "alb_dns_name" {
  description = "ALB DNS 엔드포인트"
  value       = aws_lb.main.dns_name
}

output "asg_name" {
  description = "Auto Scaling Group 이름"
  value       = aws_autoscaling_group.main.name
}

# [수정] VPC 관련 출력값 추가 (모듈이 VPC를 직접 생성하므로)
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.main.id
}
