output sec-bast-sg {
  value       = yandex_vpc_security_group.sec-bast-sg.id
}

output internal-sg {
  value       = yandex_vpc_security_group.internal-sg.id
}

output external-sg {
  value       = yandex_vpc_security_group.external-sg.id
}

output db-sg {
  value       = yandex_vpc_security_group.db-sg.id
}

output proxysql-sg {
  value       = yandex_vpc_security_group.proxysql-sg.id
}