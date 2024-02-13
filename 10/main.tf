provider "proxmox" {
  pm_api_url = var.api_url
  
  pm_api_token_id = var.token_id
  
  pm_api_token_secret = var.token_secret
  
  pm_tls_insecure = true

#   pm_log_enable = true
#   pm_log_file = "terraform-plugin-proxmox.log"
#   pm_debug = true
#   pm_log_levels = {
#     _default = "debug"
#     _capturelog = ""
#   }
}

resource "proxmox_vm_qemu" "db_hosts" {
  count = 1
  //name = "db-${count.index + 1}" 
  name = "db-${format("%02d", count.index + 1)}"
  target_node = var.proxmox_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  disk {
        slot = 0
        size = "10G"
        type = "scsi"
        storage = "local-lvm2"
        ssd = 1
    }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall  = false
    link_down = false
  }
  ipconfig0 = "ip=172.18.0.56/22,gw=172.18.0.4"
  
  ciuser = var.vm_user
  ssh_user = var.vm_user
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "backend_hosts" {
  count = 1
  //name = "db-${count.index + 1}" 
  name = "backend-${format("%02d", count.index + 1)}"
  target_node = var.proxmox_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  disk {
        slot = 0
        size = "10G"
        type = "scsi"
        storage = "local-lvm2"
        ssd = 1
    }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall  = false
    link_down = false
  }
  ipconfig0 = "ip=172.18.0.57/22,gw=172.18.0.4"
  
  ciuser = var.vm_user
  ssh_user = var.vm_user
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      db_hosts    = proxmox_vm_qemu.db_hosts[*]
      backend_hosts    = proxmox_vm_qemu.backend_hosts[*]
    }
  )
  filename = "${path.module}/inventory.txt"
}