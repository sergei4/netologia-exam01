variable "docker_image_name" {
  type = string
  default = "shvirtd-example-python"
}

locals {
  web_path = "${path.module}/../web"
}

resource "docker_image" "shvirtd-example-python" {
  name = "cr.yandex/${yandex_container_registry.registry.id}/${var.docker_image_name}"
  
  build {
    context = "${path.module}/../app"
    tag     = ["cr.yandex/${yandex_container_registry.registry.id}/${var.docker_image_name}"]
  }
  
  depends_on = [
    yandex_container_registry.registry
  ]
}

resource "null_resource" "registry_config" {
  provisioner "local-exec" {
    command    = "yc container registry configure-docker"
  }
}

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command = "docker push ${docker_image.shvirtd-example-python.name}"
  }
  depends_on = [ null_resource.registry_config ]
}

resource "local_file" "web_compose_file" {
  content = templatefile("${local.web_path}/compose.yaml.tftpl", 
  { 
    IMAGE_NAME  = docker_image.shvirtd-example-python.name,
    DB_HOST     = yandex_mdb_mysql_cluster.mysql_cluster.host[0].fqdn
    DB_NAME     = var.database_config.name,
    DB_USER     = var.database_config.user,
    DB_PASSWORD = random_password.database_user_password.result
  })
  filename = "${abspath(local.web_path)}/generated/compose.yaml"
  depends_on = [ yandex_mdb_mysql_cluster.mysql_cluster ]
}