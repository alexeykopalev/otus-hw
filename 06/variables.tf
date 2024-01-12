variable "token" {
  description = "Yandex Cloud security OAuth token"
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
}

variable "cloud_id" {
  description = "Идентификатор Yandex Cloud"
}

variable "service_account_id" {
  description = "Идентификатор сервисного аккаунта"
}

variable "bast_host_nat_ip" {
  description = "Внешний IP-адрес бастионного хоста"
}

variable "web_nat_ip" {
  description = "Внешний IP-адрес web-сервера"
}