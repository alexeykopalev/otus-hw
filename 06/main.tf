# Declaring variables for user-defined parameters

variable "dns_zone" {
  type = string
}

variable "dns_recordset_name" {
  type = string
}

# Adding other parameters

locals {
  network_name       = "network1"
  subnet_name1       = "subnet-a"
  subnet_name2       = "subnet-b"
  subnet_name3       = "subnet-c"
  sg_vm_name         = "sg-vm"
  sg_pgsql_name      = "sg-pgsql"
  dns_zone_name      = "zone-1"
}

# Configuring the provider

provider "yandex" {
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

# Creating a cloud network

resource "yandex_vpc_network" "network1" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "subnet-bast" {
  name           = "subnet-bast"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["172.16.16.0/24"]
}

# # Creating a subnet in ru-central1-a availability zone

resource "yandex_vpc_subnet" "subnet-a" {
  name           = local.subnet_name1
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.10.5.0/24"]
  network_id     = yandex_vpc_network.network1.id
  route_table_id = yandex_vpc_route_table.rt.id
}

# Creating a subnet in ru-central1-b availability zone

resource "yandex_vpc_subnet" "subnet-b" {
  name           = local.subnet_name2
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.10.6.0/24"]
  network_id     = yandex_vpc_network.network1.id
  route_table_id = yandex_vpc_route_table.rt.id
}

# # Creating a subnet in ru-central1-c availability zone

resource "yandex_vpc_subnet" "subnet-c" {
  name           = local.subnet_name3
  zone           = "ru-central1-c"
  v4_cidr_blocks = ["10.10.7.0/24"]
  network_id     = yandex_vpc_network.network1.id
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "test-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  network_id = yandex_vpc_network.network1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Creating a security group for bastion host

module "bast-sec-sg-create" {
  source = "./modules/sg-create"
  name = "bast-sec-sg"
  network_id = yandex_vpc_network.network1.id
  rules = [
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "Разрешить SSH"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    },
    {
      direction      = "ingress"
      protocol       = "ICMP"
      description    = "Разрешить ping"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      direction      = "egress"
      protocol       = "ANY"
      description    = "Разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
     },
  ]
}

# Creating a security group for web-vm and pg-vm
module "back-sec-sg-create" {
  source = "./modules/sg-create"
  name = "back-sec-sg"
  network_id = yandex_vpc_network.network1.id
  rules = [
    {
      direction      = "egress"
      protocol       = "ANY"
      description    = "Разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
     },
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "Разрешить SSH от бастионного хоста"
      v4_cidr_blocks = ["172.16.16.0/24"]
      //security_group_id = [module.bast-sec-sg-create.sg_id]
      port           = 22
    },
    {
      direction      = "ingress"
      protocol       = "ICMP"
      description    = "Разрешить ping"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    // balancer
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "Balancer"
      v4_cidr_blocks = ["0.0.0.0/0"]
      //security_group_id = "${module.ext-sec-sg-create.sg_id}"
      port              = 80
    },

    //6432
    {
      direction      = "ingress"
      description    = "balancer helpcheck"
      port           = 6432
      protocol       = "TCP"
      v4_cidr_blocks = [
        "198.18.235.0/24",
        "198.18.248.0/24"
      ]
    },
    // 80
    {
      direction      = "ingress"
      description    = "allow http subnets"
      port           = 80
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 3260
    {
      direction      = "ingress"
      description    = "allow iscsi 3620 subnets"
      port           = 3260
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 2224
    {
      direction      = "ingress"
      description    = "allow pcsd port subnets"
      port           = 2224
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 3121
    {
      direction      = "ingress"
      description    = "allow crmd port subnets"
      port           = 3121
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 5403
    {
      direction      = "ingress"
      description    = "allow corosync-qnetd subnets"
      port           = 5403
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 5404 UDP
    {
      direction      = "ingress"
      description    = "allow corosync multicast-udp subnets"
      port           = 5404
      protocol       = "UDP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 5405 UDP
    {
      direction      = "ingress"
      description    = "allow corosync subnets"
      port           = 5405
      protocol       = "UDP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 21064
    {
      direction      = "ingress"
      description    = "allow CLVM subnets"
      port           = 21064
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 9929
    {
      direction      = "ingress"
      description    = "allow booth ticket manager subnets"
      port           = 9929
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    // 9929 UDP
    {
      direction      = "ingress"
      description    = "allow UDP booth ticket manager subnets"
      port           = 9929
      protocol       = "UDP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
    {
      direction      = "ingress"
      description    = "6432"
      port           = 6432
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
     # predefined_target
  ]
}

# Creating a security group for PostgreSQL cluster
module "pgsql-sec-sg-create" {
  source = "./modules/sg-create"
  name = "pgsql-sec-sg"
  network_id = yandex_vpc_network.network1.id
  rules = [
    {
      direction      = "egress"
      protocol       = "ANY"
      description    = "Разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
     },
    {
      direction      = "ingress"
      protocol       = "ICMP"
      description    = "Разрешить ping"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "Разрешить SSH от бастионного хоста"
      v4_cidr_blocks = ["172.16.16.0/24"]
      port           = 22
    },

    // 5432
    {
      direction      = "ingress"
      description    = "PostgreSQL subnets"
      port           = 5432
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },

    // 2379
    {
      direction      = "ingress"
      description    = "etcd1 subnets"
      port           = 2379
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },

    // 2380
    {      
      direction      = "ingress"
      description    = "etcd2 subnets"
      port           = 2380
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },

    // 8008
    {
      direction      = "ingress"
      description    = "patroni rest api subnet-a"
      port           = 8008
      protocol       = "TCP"
      v4_cidr_blocks = [
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24"
      ]
    },
  ]
}

module "ext-sec-sg-create" {
  source = "./modules/sg-create"
  name = "ext-sec-sg"
  network_id = yandex_vpc_network.network1.id
  rules = [
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "Разрешить SSH от бастионного хоста"
      v4_cidr_blocks = ["172.16.16.0/24"]
      port           = 22
    },
    {
      direction      = "ingress"
      protocol       = "ICMP"
      description    = "Разрешить ping"
      v4_cidr_blocks = ["0.0.0.0/0"]
    },
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "ext-http"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 80
    },
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "ext-https"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    },
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "healthchecks"
      v4_cidr_blocks = [
        "198.18.235.0/24",
        "198.18.248.0/24"
        ]
      port           = 30080
    },
    {
      direction      = "egress"
      protocol       = "ANY"
      description    = "Разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
     },
  ]
}

# # Creating a virtual machine

module "bast-host" {
  source = "./modules/vm-create"
  name = "bast-host-srv"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "bast-host-srv"
  cpu = 2
  ram = 2
  sec_disk_id = {}
  core_fraction = 20
  subnetwork_id = yandex_vpc_subnet.subnet-bast.id
  nat = true
  ip = "172.16.16.254"
  nat-ip = var.bast_host_nat_ip
  sec-gr = [module.bast-sec-sg-create.sg_id]
}

resource "yandex_compute_disk" "iscsi-disk" {
  count     = 1
  name       = "iscsi-disk-01"
  type       = "network-hdd"
  zone       = "ru-central1-a"
  size       = 15
}

module "iscsi-srv" {
  source = "./modules/vm-create"
  name = "iscsi-srv"
  platform = "standard-v1"
  zone = "ru-central1-a"
  hostname = "iscsi-srv"
  cpu = 2
  ram = 2
  core_fraction = 20
  image_id = "fd81prb1447ilqb2mp3m"
  disk_size = 10
  sec_disk_id = {
    for disk in yandex_compute_disk.iscsi-disk :
    disk.name => {
      disk_id = disk.id
    }
    if disk.name == "iscsi-disk-01"
  }

  subnetwork_id = yandex_vpc_subnet.subnet-a.id
  nat = false
  ip = "10.10.5.3"
  sec-gr = [module.back-sec-sg-create.sg_id]
}

locals {
  back_vms = [
    {
      name       = "back-host1"
      zone       = "ru-central1-a"
      subnetwork_id = "${yandex_vpc_subnet.subnet-a.id}"
      ip_address = "10.10.5.10"
    },
    {
      name       = "back-host2"
      zone       = "ru-central1-b"
      subnetwork_id = "${yandex_vpc_subnet.subnet-b.id}"
      ip_address = "10.10.6.10"
    },
    {
      name       = "back-host3"
      zone       = "ru-central1-c"
      subnetwork_id = "${yandex_vpc_subnet.subnet-c.id}"
      ip_address = "10.10.7.10"
    }
  ]
}

module "back-hosts" {
  for_each   = {for index, vm in local.back_vms:
    vm.name => vm
  }
  source = "./modules/vm-create"
  name = each.value.name
  platform = "standard-v1"
  zone = each.value.zone
  hostname = each.value.name
  cpu = 2
  ram = 2
  image_id = "fd81prb1447ilqb2mp3m"
  disk_size = 10
  sec_disk_id = {}
  core_fraction = 100
  subnetwork_id = each.value.subnetwork_id
  ip = each.value.ip_address
  sec-gr = [module.back-sec-sg-create.sg_id]
}

locals {
  db_vms = [
    {
      name       = "db-host1"
      zone       = "ru-central1-a"
      subnetwork_id = "${yandex_vpc_subnet.subnet-a.id}"
      ip_address = "10.10.5.4"
    },
    {
      name       = "db-host2"
      zone       = "ru-central1-b"
      subnetwork_id = "${yandex_vpc_subnet.subnet-b.id}"
      ip_address = "10.10.6.4"
    },
    {
      name       = "db-host3"
      zone       = "ru-central1-c"
      subnetwork_id = "${yandex_vpc_subnet.subnet-c.id}"
      ip_address = "10.10.7.4"
    }
  ]
}

module "db-hosts" {
  for_each   = {for index, vm in local.db_vms:
    vm.name => vm
  }
  source = "./modules/vm-create"
  name = each.value.name
  platform = "standard-v1"
  zone = each.value.zone
  hostname = each.value.name
  cpu = 2
  ram = 2
  image_id = "fd81prb1447ilqb2mp3m"
  disk_size = 10
  sec_disk_id = {}
  core_fraction = 20
  subnetwork_id = each.value.subnetwork_id
  ip = each.value.ip_address
  sec-gr = [module.pgsql-sec-sg-create.sg_id]
}

resource "yandex_lb_target_group" "db-tg" {
  name      = "db-tg"
  region_id = "ru-central1"
  //folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-a.id}"
    address   = "10.10.5.10"
  }
  target {
    subnet_id = "${yandex_vpc_subnet.subnet-b.id}"
    address   = "10.10.6.10"
  }
  target {
    subnet_id = "${yandex_vpc_subnet.subnet-c.id}"
    address   = "10.10.7.10"
  }
  # dynamic "target" {
  #   for_each = data.yandex_compute_instance.nginx-servers[*].network_interface.0.ip_address
  #   content {
  #     subnet_id = yandex_vpc_subnet.subnets["lab-subnet"].id
  #     address   = target.value
  #   }
  # }
}

resource "yandex_lb_network_load_balancer" "db-nlb" {
  name = "db-nlb"
  type = "internal"

  listener {
    name = "my-listener"
    port = 6432
    internal_address_spec {
      subnet_id = yandex_vpc_subnet.subnet-a.id
      ip_version = "ipv4"
      address = "10.10.5.5"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.db-tg.id}"

    healthcheck {
      name = "tcp-6432"
      tcp_options {
        port = 6432
      }
    }
  }
}

# Creating a ALB

resource "yandex_alb_target_group" "alb-tg" {
  name           = "alb-tg"
  target {
    subnet_id    = yandex_vpc_subnet.subnet-a.id
    ip_address   = "10.10.5.10"
  }
  target {
    subnet_id    = yandex_vpc_subnet.subnet-b.id
    ip_address   = "10.10.6.10"
  }
  target {
    subnet_id    = yandex_vpc_subnet.subnet-c.id
    ip_address   = "10.10.7.10"
  }
}

resource "yandex_alb_backend_group" "alb-bg" {
  name                     = "alb-bg"

  http_backend {
    name                   = "backend-1"
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.alb-tg.id]
    healthcheck {
      timeout              = "10s"
      interval             = "10s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "alb-router" {
  name   = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
  authority      = ["dip-akopalev.ru"]
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.network1.id
  security_group_ids = [module.ext-sec-sg-create.sg_id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-b.id
    }

    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.subnet-c.id
    }

  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = var.web_nat_ip
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}

# Creating a Cloud DNS zone

resource "yandex_dns_zone" "joomla-pg" {
  name    = local.dns_zone_name
  zone    = var.dns_zone
  public  = true
}

# Creating a DNS A record

resource "yandex_dns_recordset" "joomla-pg-a" {
  zone_id = yandex_dns_zone.joomla-pg.id
  name    = var.dns_recordset_name
  type    = "A"
  ttl     = 600
  data    = [ var.web_nat_ip ]
}

# Creating a DNS CNAME record

resource "yandex_dns_recordset" "joomla-pg-cname" {
  zone_id = yandex_dns_zone.joomla-pg.id
  name    = "www"
  type    = "CNAME"
  ttl     = 600
  data    = [ var.dns_zone ]
}