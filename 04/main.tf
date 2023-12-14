provider "yandex" {
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

module "network-create" {
  source = "./modules/network-create"
  name_network1 = "network1"
  name_subnetwork1 = "subnet-1"
  name_subnetbast = "subnet-bast"
}

module "sg-create" {
  source = "./modules/sg-create"
  vpc_id = module.network-create.network1_id
}

module "bast-host" {
  source = "./modules/vm-create"
  name = "bast-host-srv"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "bast-host-srv"
  cpu = 2
  ram = 2
  core_fraction = 20
  subnetwork_id = module.network-create.subnetbast_id
  nat = true
  ip = "172.16.16.254"
  nat-ip = "158.160.84.164"
  sec-gr = [module.sg-create.sec-bast-sg]
}

module "backend" {
  count = 2
  source = "./modules/vm-create"
  name = "backend${count.index+1}"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "backend${count.index+1}"
  cpu = 2
  ram = 2
  core_fraction = 5
  preemptible = true
  image_id = "fd81prb1447ilqb2mp3m"
  disk_size = 10
  subnetwork_id = module.network-create.subnetwork1_id
  nat = false
  ip = "10.10.1.${count.index+10}"
  sec-gr = [module.sg-create.internal-sg]
}

module "nginx" {
  source = "./modules/vm-create"
  name = "nginx-srv"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "nginx-srv"
  cpu = 2
  ram = 2
  core_fraction = 20
  preemptible = true
  disk_size = 10
  image_id = "fd84nt41ssoaapgql97p"
  subnetwork_id = module.network-create.subnetwork1_id
  nat = true
  ip = "10.10.1.3"
  nat-ip = "158.160.75.138"
  sec-gr = [module.sg-create.internal-sg,module.sg-create.external-sg]
}

module "db" {
  source = "./modules/vm-create"
  name = "db-srv"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "db-srv"
  cpu = 2
  ram = 2
  core_fraction = 5
  preemptible = true
  disk_size = 10
  image_id = "fd81prb1447ilqb2mp3m"
  subnetwork_id = module.network-create.subnetwork1_id
  nat = false
  ip = "10.10.1.4"
  sec-gr = [module.sg-create.internal-sg]
}

resource "yandex_dns_zone" "zone1" {
  name        = "zone1"
  description = "Public zone"
  zone        = "dip-akopalev.ru."
  public      = true
}

resource "yandex_dns_recordset" "rs-1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "dip-akopalev.ru."
  ttl     = 600
  type    = "A"
  data    = ["158.160.75.138"]
}

resource "yandex_dns_recordset" "rs-2" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "www"
  ttl     = 600
  type    = "CNAME"
  data    = ["dip-akopalev.ru"]
}