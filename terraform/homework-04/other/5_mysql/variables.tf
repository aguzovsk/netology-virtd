variable "network_id" {
  type = string
}

variable "subnets" {
  type = list(object({
    subnet_id = string
    zone      = string
  }))

  nullable = true
  default  = null

  validation {
    condition = (var.subnets != null ?
      length(setsubtract(flatten(var.subnets[*].zone), ["ru-central1-a", "ru-central1-b", "ru-central1-c", "ru-central1-d"])) == 0 :
      true
    )
    error_message = "Some provided zones are not supported"
  }
}

variable "db_users" {
  type = list(object({
    name                  = string,
    password              = string,
    roles                 = optional(set(string), ["ALL"])
    global_permissions    = optional(set(string), ["PROCESS"])
    authentication_plugin = optional(string, "SHA256_PASSWORD")
  }))
  default = [{
    name     = "john"
    password = "password"
    roles    = ["ALL", "INSERT"]
    }, {
    name     = "peejohn"
    password = "new_password"
    roles    = ["CREATE_TEMPORARY_TABLES", "SHOW_VIEW", "LOCK_TABLES", "EXECUTE"]
  }]
  validation {
    condition = length(setsubtract(flatten(var.db_users[*].roles), [
      "ALL", "ALTER", "ALTER_ROUTINE", "CREATE", "CREATE_ROUTINE", "CREATE_TEMPORARY_TABLES", "CREATE_VIEW",
      "DELETE", "DROP", "EVENT", "EXECUTE", "INDEX", "INSERT", "LOCK_TABLES", "SELECT", "SHOW_VIEW", "TRIGGER", "UPDATE"
    ])) == 0
    error_message = "Some provided roles are not applicable"
  }

  validation {
    condition     = length(setsubtract(flatten(var.db_users[*].global_permissions), ["REPLICATION_CLIENT", "REPLICATION_SLAVE", "PROCESS"])) == 0
    error_message = "Global Permissions should be subset of ['REPLICATION_CLIENT', 'REPLICATION_SLAVE', 'PROCESS']"
  }

  validation {
    condition     = length(setsubtract(var.db_users[*].authentication_plugin, ["MYSQL_NATIVE_PASSWORD", "CACHING_SHA2_PASSWORD", "SHA256_PASSWORD"])) == 0
    error_message = "Authentication plugin should be one of 'MYSQL_NATIVE_PASSWORD', 'CACHING_SHA2_PASSWORD', 'SHA256_PASSWORD'"
  }
}
