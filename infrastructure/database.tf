variable "mysql_cluster_config" {
  type = object({
    resource_type = string
    disk_type = string
    disk_size = number
  })
}

variable "database_config" {
  type = object({
    name = string
    user = string
  })
}

resource "random_password" "database_user_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "yandex_mdb_mysql_cluster" "mysql_cluster" {
  name        = "${var.env}-mysql_cluster"
  environment = var.env == "production" ? "PRODUCTION" : "PRESTABLE"
  network_id  = yandex_vpc_network.network.id
  version     = "8.0"

  resources {
    resource_preset_id = var.mysql_cluster_config.resource_type
    disk_type_id       = var.mysql_cluster_config.disk_type
    disk_size          = var.mysql_cluster_config.disk_size
  }

  database {
    name = var.database_config.name
  }

  user {
    name     = var.database_config.user
    password = random_password.database_user_password.result
    permission {
      database_name = var.database_config.name
      roles         = ["ALL"]
    }
  }

  host {
    zone      = var.default_zone
    subnet_id = yandex_vpc_subnet.default.id
    name      = "${var.env}-mysql_cluster-primary"
  }

}

output "database_host" {
  value = {
    for host in yandex_mdb_mysql_cluster.mysql_cluster.host :
    host.name => "${host.fqdn}"
  }
}