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
