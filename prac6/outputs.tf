output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_web_subnet_ids" {
  description = "프라이빗 웹 서브넷 IDs"
  value       = module.vpc.private_web_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}
