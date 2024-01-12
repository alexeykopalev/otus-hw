output "ip" {
  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}

output "disk_id" {
  value = yandex_compute_instance.vm.boot_disk.0.disk_id
}
