# splat 표현식([*])으로 count 리소스 전체의 속성을 리스트로 추출
output "db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}

output "db_subnet_names" {
  value = aws_subnet.private_db[*].tags.Name
}
