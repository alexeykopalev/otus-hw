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
    {
      direction      = "ingress"
      protocol       = "TCP"
      description    = "PostgreSQL"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 6432
    }
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
  sec-gr = [module.vms-sec-sg-create.sg_id]
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