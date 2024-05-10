resource "yandex_compute_disk" "ya-storage-1" {
  count = 3
  type  = "network-hdd"
  size  = 1
}

resource "yandex_compute_instance" "storage-vm" {
  name = "storage-vm"

  platform_id = var.platform_id
  resources {
    cores         = var.vm-v3-minimal.cores
    memory        = var.vm-v3-minimal.memory
    core_fraction = var.vm-v3-minimal.fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.is_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    # security_group_ids = [yandex_vpc_security_group.example.id]
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.ya-storage-1[*]
    content {
      auto_delete = true
      disk_id     = secondary_disk.value.id
    }
  }

  metadata = local.metadata
}
