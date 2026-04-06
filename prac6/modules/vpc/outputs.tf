output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = aws_subnet.public[*].id
}

output "private_web_subnet_ids" {
  description = "프라이빗 웹 서브넷 ID 목록"
  value       = aws_subnet.private_web[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = var.enable_nat_gateway ? aws_nat_gateway.nat[0].id : null
}
