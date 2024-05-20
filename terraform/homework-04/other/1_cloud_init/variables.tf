variable "network_id" {
  type = string
}

variable "subnet" {
  type = object({
    subnet_id = string
    zone      = string
  })

  validation {
    condition     = contains(["ru-central1-a", "ru-central1-b", "ru-central1-c", "ru-central1-d"], var.subnet.zone)
    error_message = "Provided zone is not supported"
  }
}

variable "vm_web_os_family" {
  type    = string
  default = "ubuntu-2004-lts"
}
