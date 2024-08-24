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
