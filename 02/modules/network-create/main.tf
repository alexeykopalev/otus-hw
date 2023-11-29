resource "yandex_vpc_network" "network-1" {
  name = var.name_network1
}

resource "yandex_vpc_subnet" "subnet-1" {
  name = var.name_subnetwork1
  zone           = "ru-central1-b"
  network_id = yandex_vpc_network.network-1.id
  v4_cidr_blocks = [var.sub1_cidr1_v4]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-bast" {
  name           = var.name_subnetbast
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = [var.bast_cidr3_v4]
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "test-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
