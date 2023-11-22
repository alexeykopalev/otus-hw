provider "yandex" {
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

module "network-create" {
  source = "./modules/network-create"
  name_network1 = "network1"
  name_subnetwork1 = "subnet-1"
  name_subnetwork2 = "subnet-2"
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

resource "yandex_compute_disk" "iscsi-disk" {
  name       = "iscsi-disk"
  type       = "network-hdd"
  zone       = "ru-central1-b"
  size       = 10
}

resource "yandex_compute_instance" "iscsi-srv" {

  name                      = "iscsi-srv"
  platform_id               = "standard-v1"
  zone                      = "ru-central1-b"
  hostname                  = "iscsi-srv" 

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size = 5
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.iscsi-disk.id
  }

  network_interface {
    subnet_id = module.network-create.subnetwork1_id
    nat = false
    ip_address = "10.10.1.3"
    security_group_ids = [module.sg-create.prom-sg]
  }

  metadata = {
    user-data = "${file("./cloud-config")}"
  }
}

module "pcs" {
  count = 3
  source = "./modules/vm-create"
  name = "pcs${count.index+1}"
  platform = "standard-v1"
  zone = "ru-central1-b"
  hostname = "pcs${count.index+1}"
  cpu = 2
  ram = 4
  core_fraction = 20
  disk_size = 10
  subnetwork_id = module.network-create.subnetwork1_id
  nat = false
  ip = "10.10.1.${count.index+10}"
  sec-gr = [module.sg-create.prom-sg]
}

# module "grafana" {
#   source = "./modules/vm-create"
#   name = "grafana-srv"
#   platform = "standard-v1"
#   zone = "ru-central1-a"
#   hostname = "grafana-srv"
#   ip = "172.16.16.253"
#   nat-ip = "51.250.73.145"
#   cpu = 2
#   ram = 4
#   core_fraction = 20
#   disk_size = 5
#   subnetwork_id = module.network-create.subnetbast_id
#   nat = true
#   sec-gr = [module.sg-create.grafana-sg]
# }

# module "elastic" {
#   source = "./modules/vm-create"
#   name = "elastic-srv"
#   platform = "standard-v1"
#   zone = "ru-central1-a"
#   hostname = "elastic-srv"
#   cpu = 4
#   ram = 6
#   core_fraction = 20
#   //image_id = "fd8j8m926pr7bbo0ckco"//debian10
#   disk_size = 10
#   subnetwork_id = module.network-create.subnetwork1_id
#   nat = false
#   ip = "10.10.1.4"
#   sec-gr = [module.sg-create.elast-sg]
# }

# module "kibana" {
#   source = "./modules/vm-create"
#   name = "kibana-srv"
#   platform = "standard-v1"
#   zone = "ru-central1-a"
#   hostname = "kibana-srv"
#   ip = "172.16.16.252"
#   nat-ip = "158.160.96.201"
#   cpu = 2
#   ram = 4
#   core_fraction = 20
#   //image_id = "fd8j8m926pr7bbo0ckco"//debian10
#   disk_size = 5
#   subnetwork_id = module.network-create.subnetbast_id
#   nat = true
#   sec-gr = [module.sg-create.kibana-sg]
# }

# data "yandex_compute_instance" "websrv1_id" {
#   instance_id = yandex_compute_instance_group.alb-vm-group.instances.0.instance_id
# }

# data "yandex_compute_instance" "websrv2_id" {
#   instance_id = yandex_compute_instance_group.alb-vm-group.instances.1.instance_id
# }