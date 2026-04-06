output "alb_dns_name" {
  description = "ALB DNS 엔드포인트 (브라우저 접속 URL)"
  value       = "http://${aws_lb.web.dns_name}"
}

output "asg_name" {
  description = "Auto Scaling Group 이름"
  value       = aws_autoscaling_group.web.name
}

output "ubuntu_ami_id" {
  description = "조회된 Ubuntu 24.04 AMI ID"
  value       = data.aws_ami.ubuntu.id
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.web.id
}
