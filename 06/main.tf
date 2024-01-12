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
  # subnet_name1       = "subnet-a"
  subnet_name2       = "subnet-b"
  # subnet_name3       = "subnet-c"
  sg_vm_name         = "sg-vm"
  # sg_pgsql_name      = "sg-pgsql"
  # vm_name            = "joomla-pg-tutorial-web"
  # cluster_name       = "joomla-pg-tutorial-db-cluster"
  # db_name            = "joomla-pg-tutorial-db"
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

# resource "yandex_vpc_subnet" "subnet-a" {
#   name           = local.subnet_name1
#   zone           = "ru-central1-a"
#   v4_cidr_blocks = ["10.10.5.0/24"]
#   network_id     = yandex_vpc_network.joomla-pg-network.id
#   route_table_id = yandex_vpc_route_table.rt.id
# }

# Creating a subnet in ru-central1-b availability zone

resource "yandex_vpc_subnet" "subnet-b" {
  name           = local.subnet_name2
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.10.6.0/24"]
  network_id     = yandex_vpc_network.network1.id
  route_table_id = yandex_vpc_route_table.rt.id
}

# # Creating a subnet in ru-central1-c availability zone

# resource "yandex_vpc_subnet" "subnet-c" {
#   name           = local.subnet_name3
#   zone           = "ru-central1-c"
#   v4_cidr_blocks = ["10.7.0.0/24"]
#   network_id     = yandex_vpc_network.joomla-pg-network.id
#   route_table_id = yandex_vpc_route_table.rt.id
# }

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
module "vms-sec-sg-create" {
  source = "./modules/sg-create"
  name = "vms-sec-sg"
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
      //security_group_id = "${module.bast-sec-sg-create.sg_id}"
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
      description    = "PostgreSQL"
      port           = 5432
      protocol       = "TCP"
      v4_cidr_blocks = ["10.10.6.0/24"]
    },
    {
      direction      = "ingress"
      description    = "http"
      port           = 80
      protocol       = "TCP"
      v4_cidr_blocks = ["0.0.0.0/0"]
  }
     # predefined_target
  ]
}

# resource "yandex_vpc_security_group" "pgsql-sg" {
#   name       = local.sg_pgsql_name
#   network_id = yandex_vpc_network.joomla-pg-network.id

#   egress {
#     protocol       = "ANY"
#     description    = "ANY"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 0
#     to_port        = 65535
#   }

#   ingress {
#     description    = "PostgreSQL"
#     port           = 6432
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Creating a security group for the virtual machine

# resource "yandex_vpc_security_group" "vm-sg" {
#   name       = local.sg_vm_name
#   network_id = yandex_vpc_network.joomla-pg-network.id

#   egress {
#     protocol       = "ANY"
#     description    = "ANY"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 0
#     to_port        = 65535
#   }

#   ingress {
#     description    = "HTTP"
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 80
#   }

#   ingress {
#     description    = "HTTPS"
#     protocol       = "TCP"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 443
#   }

#   ingress {
#     description    = "SSH"
#     protocol       = "ANY"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     port           = 22
#   }
# }

# # Creating a disk image from a Cloud Marketplace product

# resource "yandex_compute_image" "joomla-pg-vm-image" {
#   source_family = "centos-stream-8"
# }

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

module "web-host" {
  source = "./modules/vm-create"
  name = "web-host"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "web-host"
  cpu = 2
  ram = 2
  image_id = "fd81prb1447ilqb2mp3m"
  disk_size = 10
  sec_disk_id = {}
  core_fraction = 20
  subnetwork_id = yandex_vpc_subnet.subnet-b.id
  nat = true
  ip = "10.10.6.3"
  nat-ip = var.web_nat_ip
  sec-gr = [module.vms-sec-sg-create.sg_id]
}

module "db-host" {
  source = "./modules/vm-create"
  name = "db-host"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "db-host"
  cpu = 2
  ram = 2
  image_id = "fd81prb1447ilqb2mp3m"
  disk_size = 10
  sec_disk_id = {}
  core_fraction = 20
  subnetwork_id = yandex_vpc_subnet.subnet-b.id
  ip = "10.10.6.4"
  sec-gr = [module.vms-sec-sg-create.sg_id]
}
# resource "yandex_compute_instance" "joomla-pg-vm" {
#   name               = local.vm_name
#   platform_id        = "standard-v3"
#   zone               = "ru-central1-b"

#   resources {
#     cores         = 2
#     memory        = 1
#     core_fraction = 20
#   }

#   boot_disk {
#     initialize_params {
#       image_id = yandex_compute_image.joomla-pg-vm-image.id
#       size     = 10
#     }
#   }

#   network_interface {
#     subnet_id          = yandex_vpc_subnet.joomla-pg-network-subnet-b.id
#     nat                = true
#     nat_ip_address     = var.nat_ip
#     security_group_ids = [ yandex_vpc_security_group.vm-sg.id ]
#   }

#   metadata = {
#     user-data = file("./cloud-config")
#   }
# }

# # Creating a PostgreSQL cluster

# resource "yandex_mdb_postgresql_cluster" "joomla-pg-cluster" {
#   name                = local.cluster_name
#   environment         = "PRODUCTION"
#   network_id          = yandex_vpc_network.joomla-pg-network.id
#   security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]

#   config {
#     version = "14"
#     resources {
# //      resource_preset_id = "b2.medium"
#       resource_preset_id = "c3-c2-m4"
#       disk_type_id       = "network-ssd"
#       disk_size          = 10
#     }
#   }

#   host {
#     zone      = "ru-central1-a"
#     subnet_id = yandex_vpc_subnet.joomla-pg-network-subnet-a.id
#   }

#   host {
#     zone      = "ru-central1-b"
#     subnet_id = yandex_vpc_subnet.joomla-pg-network-subnet-b.id
#   }

#   host {
#     zone      = "ru-central1-c"
#     subnet_id = yandex_vpc_subnet.joomla-pg-network-subnet-c.id
#   }
# }

# # Creating a database

# resource "yandex_mdb_postgresql_database" "joomla-pg-tutorial-db" {
#   cluster_id = yandex_mdb_postgresql_cluster.joomla-pg-cluster.id
#   name       = local.db_name
#   owner      = var.db_user
# }

# # Creating a database user

# resource "yandex_mdb_postgresql_user" "joomla-user" {
#   cluster_id = yandex_mdb_postgresql_cluster.joomla-pg-cluster.id
#   name       = var.db_user
#   password   = var.db_password
# }

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