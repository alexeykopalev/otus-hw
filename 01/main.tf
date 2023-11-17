provider "yandex" {
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

module "network-create" {
  source = "./modules/network-create"
  name_network1 = "network1"
  name_subnetwork1 = "subnet-1"
}

module "nginxSRV-create" {
  source = "./modules/vm-create"
  name = "web-srv1"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "web-srv1"
  ip = "10.10.1.5"
  nat_ip = "158.160.84.164"
  cpu = 2
  ram = 2
  core_fraction = 5
  disk_size = 5
  subnetwork_id = module.network-create.subnetwork1_id
  nat = true
}
