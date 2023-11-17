resource "yandex_vpc_network" "network-1" {
  name = var.name_network1
}

resource "yandex_vpc_subnet" "subnet-1" {
  name = var.name_subnetwork1
  zone           = "ru-central1-b"
  network_id = yandex_vpc_network.network-1.id
  v4_cidr_blocks = [var.sub1_cidr1_v4]
}

