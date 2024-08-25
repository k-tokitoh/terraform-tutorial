# READMEに記載のとおりimportする
resource "aws_acm_certificate" "existing_cerfiticate" {
  domain_name = "*.${var.domain}"

  lifecycle {
    prevent_destroy = true
  }
}
