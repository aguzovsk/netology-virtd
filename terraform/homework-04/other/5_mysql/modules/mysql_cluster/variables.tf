variable "network_id" {
  type        = string
  description = "Network ID, in which cluster should deployed"
}

variable "cluster_name" {
  type        = string
  description = "Name of yandex_mdb_mysql_cluster"

}

variable "subnets" {
  type = list(object({
    subnet_id = string
    zone      = string
  }))

  default = null

  validation {
    condition     = var.subnets == null ? true : length(var.subnets) > 0
    error_message = "subnets list should not be empty"
  }
  # "ru-central1-c" is being deprecated, cannot create a cluster here (https://yandex.cloud/en/docs/overview/concepts/ru-central1-c-deprecation)
  validation {
    condition = (var.subnets == null ? true :
      length(setsubtract(flatten(var.subnets[*].zone), ["ru-central1-a", "ru-central1-b", "ru-central1-d"])) == 0
    )
    error_message = "Some provided zones are not supported"
  }
}

/*
If subnets are not provided, this variable should be specified
Module will try to create subnets in each AZ 
*/
variable "cidr_prefix" {
  type        = string
  default     = "172.16.35.0/26"
  description = "subnet of size /16 - /26 where 4 (at least /28) subnet chunks will be allocated, each one for Availability Zone in ru-central1 Region"

  validation {
    condition     = can(cidrhost(cidrsubnet(var.cidr_prefix, 2, 3), 15))
    error_message = "Given CIDR range cannot be divided into 4 (at least /28) ranges"
  }
}

variable "is_HA" {
  type        = bool
  default     = true
  description = "Should cluster be in HA mode or not"
}

variable "HA_hosts" {
  type        = number
  default     = 2
  description = "How many hosts should be in HA mode"
}
