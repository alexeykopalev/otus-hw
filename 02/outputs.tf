
# output "ip_vm" {
#   value = yandex_compute_instance_group.alb-vm-group.instances.*.network_interface.0.ip_address
# }

# output "test" {
#   value = "${data.yandex_compute_instance_group.data-alb-vm-group.network_interface.0.nat_ip_address}"
# }
#value = "${data.yandex_compute_instance.my_instance.network_interface.0.nat_ip_address}