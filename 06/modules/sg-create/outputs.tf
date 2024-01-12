output sg_id {
  value       = yandex_vpc_security_group.sg.id
}

output "security_group" {
  description = "Security Group"
  value       = yandex_vpc_security_group.sg
}

output "security_group_rules" {
  description = "Security Group Rules"
  value       = yandex_vpc_security_group_rule.sg_rules
}