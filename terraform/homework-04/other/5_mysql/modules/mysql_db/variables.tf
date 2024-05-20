variable "cluster_id" {
  type        = string
  description = "ID of MySQL Cluster resource"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "db_users" {
  type = list(object({
    name                  = string,
    password              = string,
    roles                 = optional(set(string), ["ALL"])
    global_permissions    = optional(set(string), ["PROCESS"])
    authentication_plugin = optional(string, "SHA256_PASSWORD")
  }))

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
