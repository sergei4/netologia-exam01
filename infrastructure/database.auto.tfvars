mysql_cluster_config = {
  resource_type = "s2.micro"
  disk_type = "network-ssd"
  disk_size = 20
}

database_config = {
  name = "virtd"
  user = "app"
}