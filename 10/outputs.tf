# output "db_hosts-info" {
#   description = "General information about created VMs"
#   value = {
#     for vm in proxmox_vm_qemu.db_hosts[*] :
#     vm.name => {
#       ip_address = vm.default_ipv4_address
#     }
#   }
# }

# output "backend_hosts-info" {
#   description = "General information about created VMs"
#   value = {
#     for vm in proxmox_vm_qemu.backend_hosts[*] :
#     vm.name => {
#       ip_address = vm.default_ipv4_address
#     }
#   }
# }