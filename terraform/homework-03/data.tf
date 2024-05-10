data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_os_family
}
