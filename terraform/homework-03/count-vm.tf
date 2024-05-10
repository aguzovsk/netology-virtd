resource "yandex_compute_instance" "webserver-vm" {
  count      = 2
  name       = "web-${count.index + 1}"
  depends_on = [yandex_compute_instance.database-vm]

  platform_id = var.platform_id
  resources {
    cores         = var.vm-v3-minimal.cores
    memory        = var.vm-v3-minimal.memory
    core_fraction = var.vm-v3-minimal.fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vm-v3-minimal.disk_size
    }
  }
  scheduling_policy {
    preemptible = var.is_preemptible
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = true
  }

  metadata = local.metadata
}
