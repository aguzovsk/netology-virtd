variable "vm_web_os_family" {
  type = string
}

variable "each_vm" {
  type = list(object({ vm_name = string, cpu = number, ram = number, disk_volume = number }))
}

variable "platform_id" {
  type = string
}

variable "is_preemptible" {
  type    = bool
  default = true
}

# variable "each_vm" {
#   type = list(object({
#     vm_name     = string,
#     cpu         = number
#     ram         = number
#     disk_volume = number
#   }))
# }

variable "vm-v3-minimal" {
  type = object({
    cores     = number
    memory    = number
    fraction  = number
    disk_size = number
  })
  default = {
    cores     = 2
    memory    = 1
    fraction  = 20
    disk_size = 5
  }
}
