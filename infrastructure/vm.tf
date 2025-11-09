variable "vm_config" {
  type = object({
    cores = number
    memory = number
    core_fraction = number
  })
}

variable "applicatin_dir" {
  type = string
  default = "/opt/web"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
}

resource "yandex_compute_instance" "platform" {
  name        = "${var.env}-vm"
  platform_id = var.yandex_vm_platform

  allow_stopping_for_update = true

  resources {
    cores         = var.vm_config.cores
    memory        = var.vm_config.memory
    core_fraction = var.vm_config.core_fraction
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  
  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    security_group_ids = [yandex_vpc_security_group.default_security_group.id]
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubunty:${file("~/.ssh/id_ed25519.pub")}"
  }

  depends_on = [ yandex_mdb_mysql_cluster.mysql_cluster ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.network_interface.0.nat_ip_address
    private_key = file("~/.ssh/id_ed25519")
    timeout     = "120s"
  }

  # Устанавливаем docker и docker-compose 
  provisioner "remote-exec" {
    inline = [
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "sudo echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  # Настройка доступа к yndex docker registry
  provisioner "remote-exec" {
    inline = [
      "echo ${var.yc_auth_token} | docker login --username oauth --password-stdin cr.yandex"
    ]
  }

  # Установка приложения
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.applicatin_dir}",
      "sudo chown ubuntu:ubuntu ${var.applicatin_dir}"
    ]
  }

  provisioner "file" {
    source      = "../web/"
    destination = "${var.applicatin_dir}"
  }

  # Запуск приложения
  provisioner "remote-exec" {
    inline = [
      "docker compose --project-directory ${var.applicatin_dir} -f ${var.applicatin_dir}/generated/compose.yaml up -d"
    ]
  }

}

output "vm" {
  value = { 
    webhost = "Адрес сервиса: http://${yandex_compute_instance.platform.network_interface[0].nat_ip_address}:8090" 
  }
}