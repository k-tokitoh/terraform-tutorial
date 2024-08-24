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
# マルチAZ配置する場合は、subnet groupに含まれる複数のsubnetに配置される
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


# ==========================================================================================================================
# instance
# ==========================================================================================================================

resource "random_string" "rds_password" {
  length = 16

  # 特殊文字を含むか否か
  special = true
}

resource "aws_db_instance" "mysql_instance" {
  engine         = "mysql"
  engine_version = "8.0"

  identifier = "${lower(var.project)}-${lower(var.environment)}-mysqlinstance"

  username = "name"

  # random stringはtfstateに平文で保存されてしまう
  # - 対策1
  #   - terraformを実行する人を、パスワードを知っていていい人に限定する
  # - 対策2
  #   - terraformを実行する人を、パスワードを知っていていい人に限定しない
  #   - terraformの実行後に、terraform外から（aws cliなどにより）パスワードを変更する
  #   - terraform上ではlifecycleの指定によって、terraformで管理されたstateと異なることが許容されるようにする
  password = random_string.rds_password.result

  instance_class = "db.t3.micro"

  # 単位はGiB
  allocated_storage     = 20
  max_allocated_storage = 50

  # gp2はデフォルトの選択肢で、汎用SSDを表す
  storage_type = "gp2"

  # ある時期からデフォルトで暗号化されるようになっている
  storage_encrypted = true

  # 今回はシングルAZで構築する
  multi_az = false
  # シングルAZなので、配置するAZを明示的に指定する必要がある
  availability_zone    = "us-east-1a"
  db_subnet_group_name = aws_db_subnet_group.mysql_subnet_group.name

  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  publicly_accessible    = false
  port                   = 3306
  db_name                = "terraformTutorial"
  parameter_group_name   = aws_db_parameter_group.mysql_paramter_group.name
  option_group_name      = aws_db_option_group.mysql_option_group.name

  # バックアップを実行する時間帯
  backup_window = "03:00-04:00"
  # バックアップの保持期間。単位は日。
  backup_retention_period = 7

  # 安全のため、バックアップの直後にメンテナンスウィンドウを設定する
  maintenance_window         = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = false

  # 個人練習用なので、頻繁に削除をする見込み。
  deletion_protection = false
  # 頻繁に削除をする見込みなので、snapshotが溜まっていくことを防ぐため、最終スナップショットはとらない設定とする
  skip_final_snapshot = true

  apply_immediately = true

  tags = {
    Name    = "${var.project}-${var.environment}-mysqlInstance"
    Project = var.project
    Env     = var.environment
  }
}
