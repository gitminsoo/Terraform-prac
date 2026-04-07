
output "alb_dns_name" {
  description = "ALB DNS 엔드포인트"
  value       = aws_lb.main.dns_name
}

output "asg_name" {
  description = "Auto Scaling Group 이름"
  value       = aws_autoscaling_group.main.name
}
