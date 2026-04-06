output "sg_id" {
  value = aws_security_group.web.id
}

output "sg_ingress_rule_count" {
  value = length(var.ingress_rules)
}
