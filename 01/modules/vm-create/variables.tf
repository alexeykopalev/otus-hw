variable "name" {
  description = "Название VM"
}

variable "platform" {
  description = "Platform YCloud"  
  default = "standard-v1"
}

variable "zone" {
  description = "Зона доступности"
  default = "ru-central1-b"
}

variable "hostname"{
  description = "Имя хоста"
  default = ""
}

variable "cpu" {
  description = "Count cores"
  default = 2
}

variable "ram" {
  description = "Count ram in Gb"
  default = 2
}

variable "image_id" {
  default = "fd8o41nbel1uqngk0op2"
  description = "ID default image for VM"
}

variable "disk_size"{
  description = "HDD size in Gb"
  default = 3
}

variable "preemptible" {
  description = "Признак прерываемости VM"
  type = bool
  default = false
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU"
  default = "20"
}

variable "subnetwork_id" {}

variable "nat" {
  description = "Включение nat для VM"
  type = bool
  default = false
}

variable "ip" {
  description = "Внутренний адрес VM"
  default = ""
}

variable "nat_ip" {
  description = "Внешний адрес VM"
  default = ""
}