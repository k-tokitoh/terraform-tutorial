# ==========================================================================================================================
# key pair
# ==========================================================================================================================

# ローカルで以下のコマンドでキーペアを生成しておき、以下によりterraform上のリソースとして登録する
# ssh-keygen -t rsa -b 2048 -f terraform-tutorial-dev-keypair
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project}-${var.environment}-keyPair"
  public_key = file("./src/terraform-tutorial-dev-keypair.pub")

  tags = {
    Name        = "${var.project}-${var.environment}-keyPair"
    project     = var.project
    Environment = var.environment
  }
}


# ==========================================================================================================================
# ec2 instance
# ==========================================================================================================================

resource "aws_instance" "application_server" {
  ami                         = data.aws_ami.application_ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true

  # インスタンスプロファイル（≒ ロール）を適用する
  iam_instance_profile = aws_iam_instance_profile.application_instance_profile.name

  vpc_security_group_ids = [aws_security_group.application_security_group.id]

  key_name = aws_key_pair.key_pair.key_name

  tags = {
    Name        = "${var.project}-${var.environment}-applicationServer"
    project     = var.project
    Environment = var.environment
    Type        = "application"
  }
}


# ==========================================================================================================================
# parameter store
# ==========================================================================================================================

resource "aws_ssm_parameter" "database_host" {
  name = "/${var.project}/${var.environment}/app/DATABASE_HOST"

  # 平文の文字列なら"String", 暗号化された文字列なら"SecureString"
  type = "String"

  # ホスト名
  # ex. terraformtutorial-dev-mysqlinstance.xxxxxxxx.us-east-1.rds.amazonaws.com
  value = aws_db_instance.mysql_instance.address
}

resource "aws_ssm_parameter" "database_port" {
  name = "/${var.project}/${var.environment}/app/DATABASE_PORT"
  type = "String"

  value = aws_db_instance.mysql_instance.port
}

resource "aws_ssm_parameter" "database_name" {
  name = "/${var.project}/${var.environment}/app/DATABASE_NAME"
  type = "String"

  value = aws_db_instance.mysql_instance.db_name
}

resource "aws_ssm_parameter" "database_username" {
  name = "/${var.project}/${var.environment}/app/DATABASE_USERNAME"
  type = "SecureString"

  value = aws_db_instance.mysql_instance.username
}

resource "aws_ssm_parameter" "database_password" {
  name = "/${var.project}/${var.environment}/app/DATABASE_PASSWORD"
  type = "SecureString"

  value = aws_db_instance.mysql_instance.password
}
