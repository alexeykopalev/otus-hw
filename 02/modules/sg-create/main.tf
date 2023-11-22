resource "yandex_vpc_security_group" "sec-bast-sg" {
  name        = "sec-bast-sg"
  network_id  = var.vpc_id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prom-sg" {
  name        = "prom-sg"
  network_id  = var.vpc_id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "allow ssh bastion"
    security_group_id = yandex_vpc_security_group.sec-bast-sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "allow iscsi 3620"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 3260
  }

  ingress {
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
