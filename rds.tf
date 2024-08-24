# ==========================================================================================================================
# parameter group
# ==========================================================================================================================

resource "aws_db_parameter_group" "mysql_paramter_group" {
  # 小文字しか指定できないとのこと
  name   = "${lower(var.project)}-${lower(var.environment)}-mysqlparametergroup"
  family = "mysql8.0"

  # RDSサーバ全体でデフォルトとして利用される文字セット
  # character_set_database が指定されない場合は、このRDSサーバが扱う全てのデータベースで、この文字セットが利用される
  # mb4はmultibyte4の略で、4バイト文字を扱うことができる文字セット
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  # 特定のデータベースで利用される文字セット
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
}
