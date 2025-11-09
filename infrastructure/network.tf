resource "yandex_vpc_network" "network" {
  name = "${var.env}-network"
}

resource "yandex_vpc_subnet" "default" {
  name           = "${var.env}-default-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.default_cidr
}