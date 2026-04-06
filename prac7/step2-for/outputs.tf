# for 표현식으로 for_each 리소스를 name→id 맵으로 변환
output "subnet_id_map" {
  value = { for name, subnet in aws_subnet.subnets : name => subnet.id }
}

# 조건 필터 — PUBLIC 서브넷 이름만 추출
output "public_subnet_names" {
  value = [for name, subnet in aws_subnet.subnets : name if can(regex("PUBLIC", name))]
}
