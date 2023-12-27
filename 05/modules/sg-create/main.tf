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

resource "yandex_vpc_security_group" "internal-sg" {
  name        = "internal-sg"
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
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "balancer"
    security_group_id = yandex_vpc_security_group.external-sg.id
    port              = 80
  }

//80
  ingress {
    protocol       = "TCP"
    description    = "allow http subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "allow http subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "allow http subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 80
  }

//3260
  ingress {
    protocol          = "TCP"
    description       = "allow iscsi 3620 subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 3260
  }

  ingress {
    protocol          = "TCP"
    description       = "allow iscsi 3620 subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 3260
  }

  ingress {
    protocol          = "TCP"
    description       = "allow iscsi 3620 subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 3260
  }

//2224
  ingress {
    protocol          = "TCP"
    description       = "allow pcsd port subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 2224
  }

  ingress {
    protocol          = "TCP"
    description       = "allow pcsd port subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 2224
  }

  ingress {
    protocol          = "TCP"
    description       = "allow pcsd port subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 2224
  }

//3121
  ingress {
    protocol          = "TCP"
    description       = "allow crmd port subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 3121
  }

  ingress {
    protocol          = "TCP"
    description       = "allow crmd port subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 3121
  }

  ingress {
    protocol          = "TCP"
    description       = "allow crmd port subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 3121
  }

//5403
  ingress {
    protocol          = "TCP"
    description       = "allow corosync-qnetd subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 5403
  }

  ingress {
    protocol          = "TCP"
    description       = "allow corosync-qnetd subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 5403
  }

  ingress {
    protocol          = "TCP"
    description       = "allow corosync-qnetd subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 5403
  }

//5404 UDP
  ingress {
    protocol          = "UDP"
    description       = "allow corosync multicast-udp subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 5404
  }

  ingress {
    protocol          = "UDP"
    description       = "allow corosync multicast-udp subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 5404
  }

  ingress {
    protocol          = "UDP"
    description       = "allow corosync multicast-udp subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 5404
  }


//5405 UDP
  ingress {
    protocol          = "UDP"
    description       = "allow corosync subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 5405
  }

  ingress {
    protocol          = "UDP"
    description       = "allow corosync subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 5405
  }

  ingress {
    protocol          = "UDP"
    description       = "allow corosync subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 5405
  }

//21064
  ingress {
    protocol          = "TCP"
    description       = "allow CLVM subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 21064
  }  

  ingress {
    protocol          = "TCP"
    description       = "allow CLVM subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 21064
  }  

  ingress {
    protocol          = "TCP"
    description       = "allow CLVM subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 21064
  }  

//9929
  ingress {
    protocol          = "TCP"
    description       = "allow booth ticket manager subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 9929
  }

  ingress {
    protocol          = "TCP"
    description       = "allow booth ticket manager subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 9929
  }

  ingress {
    protocol          = "TCP"
    description       = "allow booth ticket manager subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 9929
  }

//9929 UDP
  ingress {
    protocol          = "UDP"
    description       = "allow booth ticket manager subnet-1"
    v4_cidr_blocks    = ["10.10.1.0/24"]
    port              = 9929
  }

  ingress {
    protocol          = "UDP"
    description       = "allow booth ticket manager subnet-2"
    v4_cidr_blocks    = ["10.10.2.0/24"]
    port              = 9929
  }

  ingress {
    protocol          = "UDP"
    description       = "allow booth ticket manager subnet-3"
    v4_cidr_blocks    = ["10.10.3.0/24"]
    port              = 9929
  }
}

resource "yandex_vpc_security_group" "external-sg" {
  name        = "external-sg"
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
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "healthchecks"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    port           = 30080
  }
}

resource "yandex_vpc_security_group" "db-sg" {
  name        = "db-sg"
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
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

//3306
  ingress {
    protocol       = "TCP"
    description    = "allow 3306 subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 3306
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 3306 subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 3306
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 3306 subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 3306
  }
  //4444 
  ingress {
    protocol       = "TCP"
    description    = "allow 4444 subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 4444
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 4444 subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 4444
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 4444 subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 4444
  }

//4567
  ingress {
    protocol       = "TCP"
    description    = "allow 4567 subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 4567
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 4567 subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 4567
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 4567 subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 4567
  }

//4568
  ingress {
    protocol       = "TCP"
    description    = "allow 4568 subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 4568
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 4568 subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 4568
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 4568 subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 4568
  }
}

resource "yandex_vpc_security_group" "proxysql-sg" {
  name        = "proxysql-sg"
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
    protocol       = "ICMP"
    description    = "ping allow"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

//6032
  ingress {
    protocol       = "TCP"
    description    = "allow 6032 subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 6032
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 6032 subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 6032
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 6032 subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 6032
  }

//6033
  ingress {
    protocol       = "TCP"
    description    = "allow 6033 subnet-1"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 6033
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 6033 subnet-2"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 6033
  }

  ingress {
    protocol       = "TCP"
    description    = "allow 6033 subnet-3"
    v4_cidr_blocks = ["10.10.3.0/24"]
    port           = 6033
  }
}