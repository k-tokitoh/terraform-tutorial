# ==========================================================================================================================
# zone
# ==========================================================================================================================

# READMEに記載のとおり、手動で作成したzoneをimportしてこのリソースとして管理する
resource "aws_route53_zone" "existing_zone" {
  # ドメイン名
  name    = var.domain
  comment = "HostedZone created by Route53 Registrar"

  # terraform destroyで削除しない
  force_destroy = false
}

resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.existing_zone.zone_id
  name    = "terraform-tutorial-alb.${var.domain}"

  # Aレコードはipアドレス/AWSリソースいずれかを指定できる
  type = "A"
  alias {
    name    = aws_lb.alb.dns_name
    zone_id = aws_lb.alb.zone_id

    # ヘルスチェックをするかどうか
    evaluate_target_health = true
  }
}
