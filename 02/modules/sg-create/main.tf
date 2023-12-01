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
    protocol          = "TCP"
    description       = "allow pcsd port"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 2224
  }

      ingress {
    protocol          = "TCP"
    description       = "allow crmd port"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 3121
  }

  ingress {
    protocol          = "TCP"
    description       = "allow corosync-qnetd"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 5403
  }

  ingress {
    protocol          = "UDP"
    description       = "allow corosync multicast-udp"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 5404
  }

  ingress {
    protocol          = "UDP"
    description       = "allow corosync"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 5405
  }

  ingress {
    protocol          = "TCP"
    description       = "allow CLVM"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 21064
  }  

  ingress {
    protocol          = "TCP"
    description       = "allow booth ticket manager"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 9929
  }

  ingress {
    protocol          = "UDP"
    description       = "allow booth ticket manager"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 9929
  }

  ingress {
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
