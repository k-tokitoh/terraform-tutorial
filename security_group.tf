# ==========================================================================================================================
# web
# ==========================================================================================================================

resource "aws_security_group" "web_security_group" {
  name = "${var.project}-${var.environment}-webSecurityGroup"
  # descriptionは指定がないとランダムな文字列が入ってしまうため指定しておく
  description = "security group for web"

  # 同一dirの.tfは一度に全て読み込まれるため、下記のとおりnetwork.tfに記載されたresourceを参照できる。
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-webSecurityGroup"
    Project = var.project
    Env     = var.environment
  }
}

# security groupに登録されるルールひとつひとつがresourceとして定義される
resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_security_group.id

  # インバウンドルール
  type = "ingress"

  # セキュリティグループのルールで指定するprotocolという項目はネットワーク層のプロトコルを指定するため、指定可能な値はtcp, udp, icmp, allのいずれか
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_in_https" {
  security_group_id = aws_security_group.web_security_group.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

# 今回動かすnodeのアプリケーションはtcpの3000番ポートでリクエストを受け付ける
resource "aws_security_group_rule" "web_out_tcp3000" {
  security_group_id = aws_security_group.web_security_group.id

  # アウトバウンドルール
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3000
  to_port                  = 3000
  source_security_group_id = aws_security_group.web_security_group.id
}


# ==========================================================================================================================
# application
# ==========================================================================================================================

# ルールは追って実装する
resource "aws_security_group" "application_security_group" {
  name        = "${var.project}-${var.environment}-applicationSecurityGroup"
  description = "security group for application"

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-applicationSecurityGroup"
    Project = var.project
    Env     = var.environment
  }
}


# ==========================================================================================================================
# db
# ==========================================================================================================================

resource "aws_security_group" "db_security_group" {
  name        = "${var.project}-${var.environment}-dbSecurityGroup"
  description = "security group for db"

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-dbSecurityGroup"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "db_in_tcp3306" {
  security_group_id = aws_security_group.db_security_group.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 3306
  to_port   = 3306

  # どこからはいってきていいかは、cidr_blocksで定義するほか「このsecurity groupとの通信ならOK」と指定することができる
  # インバウンドルールなら「このsecurity groupからの通信はOK」
  # アウトバウンドルールなら「このsecurity groupへの通信はOK」
  source_security_group_id = aws_security_group.application_security_group.id
}

