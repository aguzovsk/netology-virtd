resource "yandex_mdb_mysql_database" "foo" {
  cluster_id = var.cluster_id
  name       = var.db_name
}
