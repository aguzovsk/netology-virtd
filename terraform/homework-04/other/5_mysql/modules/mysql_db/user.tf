resource "yandex_mdb_mysql_user" "given-users" {
  cluster_id = var.cluster_id
  for_each   = { for idx, user in var.db_users : idx => user }
  name       = each.value.name
  password   = each.value.password

  permission {
    database_name = yandex_mdb_mysql_database.foo.name
    roles         = each.value.roles
  }

  connection_limits {
    max_questions_per_hour   = 10
    max_updates_per_hour     = 20
    max_connections_per_hour = 30
    max_user_connections     = 40
  }

  global_permissions = each.value.global_permissions

  authentication_plugin = each.value.authentication_plugin
}
