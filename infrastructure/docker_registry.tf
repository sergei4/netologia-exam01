resource "yandex_container_registry" "registry" {
  name      = var.registry_name
  folder_id = var.folder_id
}

output "registry" {
  value = {
    registry_id = yandex_container_registry.registry.id
  }
}