resource "yandex_compute_instance" "database-vm" {
  for_each = { for index, vm in var.each_vm : index => vm }
  name     = each.value.vm_name

  platform_id = var.platform_id
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = var.vm-v3-minimal.fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = var.is_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    # nat       = true
    # security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.metadata
}
