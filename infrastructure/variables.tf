variable "env" {
  type = string
  description = "Environment"
  default = "develop"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "yc_auth_token" {
  type = string
  sensitive = true
  description = "Yandex Clouud Token"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "yandex_vm_platform" {
    type = string
    default = "standard-v3"
}

variable "registry_name" {
    type = string
    default = "main-docker-registry"
    description = "Docker Registry name"
}