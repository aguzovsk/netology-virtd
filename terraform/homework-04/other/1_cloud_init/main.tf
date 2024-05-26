module "marketing" {
  source             = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=282797c08889fb2ab78c1ac69fcd435453df860d"
  env_name           = "develop"
  network_id         = var.network_id
  subnet_zones       = [var.subnet.zone]
  subnet_ids         = [var.subnet.subnet_id]
  instance_name      = "web"
  instance_count     = 1
  image_family       = var.vm_web_os_family
  public_ip          = false
  security_group_ids = [yandex_vpc_security_group.example.id]

  labels = {
    branch  = "marketing"
    subnet  = "terraform-managed"
    version = "0.1"
  }

  metadata = local.metadata
}

module "analytics" {
  source             = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=282797c08889fb2ab78c1ac69fcd435453df860d"
  env_name           = "stage"
  network_id         = var.network_id
  subnet_zones       = [var.subnet.zone]
  subnet_ids         = [var.subnet.subnet_id]
  instance_name      = "web-stage"
  instance_count     = 1
  image_family       = var.vm_web_os_family
  public_ip          = false
  security_group_ids = [yandex_vpc_security_group.example.id]

  labels = {
    branch  = "analytics"
    subnet  = "terraform-managed"
    version = "0.1"
  }

  metadata = local.metadata
}
