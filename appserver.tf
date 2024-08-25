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

# 起動テンプレートからauto scalingすることとしたためコメントアウト
# resource "aws_instance" "application_server" {
#   ami                         = data.aws_ami.application_ami.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public_subnet_1a.id
#   associate_public_ip_address = true

#   # インスタンスプロファイル（≒ ロール）を適用する
#   iam_instance_profile = aws_iam_instance_profile.application_instance_profile.name

#   vpc_security_group_ids = [aws_security_group.application_security_group.id]

#   key_name = aws_key_pair.key_pair.key_name

#   tags = {
#     Name        = "${var.project}-${var.environment}-applicationServer"
#     project     = var.project
#     Environment = var.environment
#     Type        = "application"
#   }
# }


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


# ==========================================================================================================================
# launch template
# ==========================================================================================================================

resource "aws_launch_template" "launch_template_application" {
  # バージョン管理をしてくれる
  update_default_version = true

  name = "${var.project}-${var.environment}-launchTemplateApplication"

  image_id = data.aws_ami.application_ami.id
  key_name = aws_key_pair.key_pair.key_name

  # ec2インスタンスに付与するタグ
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.environment}-applicationServer"
      project     = var.project
      Environment = var.environment
      Type        = "application"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_security_group.id]

    # ec2が落ちた時にネットワークリソースも合わせて削除するとのこと。よくわからん
    delete_on_termination = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.application_instance_profile.name
  }

  # インスタンスを初期化するためのスクリプト
  # 実際に起動可能にするには、手動でec2に接続してos/middlewareをインストールしてその状態をAMIとして保存し、起動テンプレートからそのAMIを参照する必要がある
  user_data = filebase64("./src/initialize.sh")
}


# ==========================================================================================================================
# auto scaing group
# ==========================================================================================================================

resource "aws_autoscaling_group" "autoscaling_group_application" {
  name = "${var.project}-${var.environment}-autoscalingGroupApplication"

  max_size = 1
  min_size = 1
  # 希望するインスタンスの数
  desired_capacity = 1

  # インスタンス起動後、どれくらい経過したらヘルスチェックを行うか。単位は秒
  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  target_group_arns = [aws_lb_target_group.alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template_application.id
        version            = "$Latest"
      }

      override {
        instance_type = "t2.micro"
      }
    }
  }
}
