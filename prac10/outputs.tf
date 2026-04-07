output "instance_id" {
  description = "EC2 인스턴스 ID 입니다."
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "EC2 퍼블릭 IP"
  value       = aws_instance.web.public_ip
}

output "ami_id" {
  description = "사용된 Ubuntu 24.04 LTS AMI ID"
  value       = data.aws_ami.ubuntu.id
}

output "security_group_id" {
  description = "KMS-SG-CICD Security Group ID"
  value       = aws_security_group.web.id
}
