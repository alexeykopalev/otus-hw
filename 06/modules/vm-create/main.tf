resource "yandex_compute_instance" "vm" {
  name = var.name
  platform_id = var.platform
  zone = var.zone
  hostname = var.hostname
  allow_stopping_for_update = var.stop_for_update

  scheduling_policy {
   preemptible = var.preemptible
  }

  resources {
    cores = var.cpu
    memory = var.ram
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
        image_id = var.image_id
        size = var.disk_size
    }
  }

  dynamic "secondary_disk" {
    for_each = var.sec_disk_id
    content {
      disk_id     = lookup(secondary_disk.value, "disk_id")
      auto_delete = lookup(secondary_disk.value, "auto_delete", true)
      mode        = lookup(secondary_disk.value, "mode", "READ_WRITE")
    }
  }

  network_interface {
    subnet_id = var.subnetwork_id
    nat = var.nat
    ip_address = var.ip
    nat_ip_address = var.nat-ip
    security_group_ids = var.sec-gr
  }

  metadata = {
    user-data = file("${path.module}/cloud-config")
  }

}