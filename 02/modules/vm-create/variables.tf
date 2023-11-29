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
//  default = "fd8o41nbel1uqngk0op2"
  default = "fd83rqq627fa1mdphnog"
  description = "ID default image for VM"
}

variable "disk_size"{
  description = "HDD size in Gb"
  default = 10
}

#  variable "sec_disk_id" {
#    description = "Second disk"
#    default = ""
#  }

variable "preemptible" {
  description = "Признак прерываемости VM"
  type = bool
  default = false
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU"
  default = "5"
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

variable "nat-ip" {
  description = "Внешний адрес VM"
  default = ""
}

variable "sec-gr" {
  description = "Группа безопасности VM"
}