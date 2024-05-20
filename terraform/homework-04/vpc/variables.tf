variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "env_name" {
  type    = string
  default = "netology-network"
}

variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))

  default = [
    {
      cidr = "10.17.0.0/16",
      zone = "ru-central1-a"
    },
    {
      cidr = "10.18.0.0/16",
      zone = "ru-central1-b"
    },
    {
      cidr = "10.19.0.0/16",
      zone = "ru-central1-c"
    },
    {
      cidr = "10.20.0.0/16",
      zone = "ru-central1-d"
    }
  ]

  validation {
    condition     = length(setsubtract(flatten(var.subnets[*].zone), ["ru-central1-a", "ru-central1-b", "ru-central1-c", "ru-central1-d"])) == 0
    error_message = "Some provided zones are not supported"
  }

  validation {
    condition     = alltrue([for cidr in var.subnets[*].cidr : can(cidrhost(cidr, 15))])
    error_message = "Some provided CIDR ranges are too small. The smallest supported - /28)"
  }

  validation {
    condition     = alltrue([for cidr in var.subnets[*].cidr : !can(cidrhost(cidr, 256 * 256))])
    error_message = "Some provided CIDR ranges are too big, The biggest support - /16"
  }
}
