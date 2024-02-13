variable "token_id" {
  type = string
  description = "Proxmox API token ID"
}
variable "token_secret" {
  type = string
  description = "Proxmox API token secret"
}
variable "api_url" {
  type = string
  description = "URL Proxmox API"
}

variable "ssh_key" {
  type = string
  description = "SSH key"
}

variable "proxmox_host" {
  type = string
    description = "URL Proxmox"
}

variable "template_name" {
  type = string
  description = "template"
}

variable "vm_user" {
  type = string
  description = "user"
}