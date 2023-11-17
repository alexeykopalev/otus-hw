//output "instance_inrernal_ip" {
//output "ip_vm" {
//  value = yandex_compute_instance.server.network_interface.0.nat_ip_address
//}

// output "disk_id" {
# output "group_websrv_name1" {
#   value = yandex_compute_instance_group.alb-vm-group.instances.0.name
# }

# output "group_websrv_name2" {
#   value = yandex_compute_instance_group.alb-vm-group.instances.1.name
# }

# output "group_websrv_id0" {
#   value = yandex_compute_instance_group.alb-vm-group.instances.0.instance_id
# }

# output "group_websrv_id1" {
#   value = yandex_compute_instance_group.alb-vm-group.instances.1.instance_id
# }

# output "instance_boot_disk_id" {
#   value = "${data.yandex_compute_instance.websrv1_id.boot_disk.0.disk_id}"
# }

# output "test" {
#   value = "${data.yandex_compute_instance_group.data-alb-vm-group.network_interface.0.nat_ip_address}"
# }
#value = "${data.yandex_compute_instance.my_instance.network_interface.0.nat_ip_address}