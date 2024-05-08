variable "vm_web_os_family" {
  type = string
  default = "ubuntu-2004-lts"
}

## vm_web

# variable "vm_web_name" {
#   type = string
#   default = "netology-develop-platform-web"
# }

variable "vm_web_platform_id" {
  type = string
  default = "standard-v3"
}

# variable "vm_web_cores" {
#   type = number
#   default = 2
# }

# variable "vm_web_memory" {
#   type = number
#   default = 1
#   description = "RAM in GB"
# }

# variable "vm_web_fraction" {
#   type = number
#   default = 20
# }

# variable "vm_web_has_nat" {
#   type = bool
#   default = true
#   description = "Is NAT available"
# }

variable "vm_web_is_preemptible" {
  type = bool
  default = true
}

# variable "vm_web_serial_ports" {
#   type = number
#   default = 1
# }


## vm_db variables

# variable "vm_db_name" {
#     type = string
#     default = "netology-develop-platform-db"
# }

# variable "vm_db_cores" {
#   type = number
#   default = 2
# }

# variable "vm_db_memory" {
#   type = number
#   default = 2
#   description = "RAM in GB"
# }

# variable "vm_db_fraction" {
#   type = number
#   default = 20
# }

variable "vm_db_zone" {
  type = string
  default = "ru-central1-b"
}

variable "vm_db_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "vm_db_subnet_name" {
  type = string
  default = "db_subnet"
}

# maps

variable "vms_resources" {
  type = map(map(number))
}

variable "metadata" {
  type = object({
    serial-port-enable = optional(number)
    ssh-keys = string
  })
}