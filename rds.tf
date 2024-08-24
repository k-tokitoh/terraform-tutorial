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


# ==========================================================================================================================
# option group
# ==========================================================================================================================

resource "aws_db_option_group" "mysql_option_group" {
  name                 = "${lower(var.project)}-${lower(var.environment)}-mysqloptiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}


# ==========================================================================================================================
# subnet group
# ==========================================================================================================================

# subnet groupに指定されたいずれかのsubnetにRDSインスタンスが配置される
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name = "${lower(var.project)}-${lower(var.environment)}-mysqlsubnetgroup"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]

  tags = {
    Name        = "${var.project}-${var.environment}-mysqlSubnetGroup"
    project     = var.project
    Environment = var.environment
  }
}
