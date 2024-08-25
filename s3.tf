resource "random_string" "s3_unique_key" {
  length = 6
  # 特殊文字
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# ==========================================================================================================================
# static bucket
# ==========================================================================================================================

# 配信したい静的 = staticなファイルを配置する、privateなバケット
resource "aws_s3_bucket" "s3_static_bucket" {
  # バケット名
  bucket = "${lower(var.project)}-${lower(var.environment)}-static-${random_string.s3_unique_key.result}"

}

resource "aws_s3_bucket_public_access_block" "s3_static_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_static_bucket.bucket

  # 「パブリックアクセスOKだよ」というACLの追加をブロックする
  block_public_acls = true

  # 「パブリックアクセスOKだよ」というACLが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  ignore_public_acls = true

  # 「パブリックアクセスOKだよ」というpolicyの追加をブロックする
  block_public_policy = true

  # 「パブリックアクセスOKだよ」というpolicyが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_static_bucket_policy" {
  bucket = aws_s3_bucket.s3_static_bucket.bucket
  policy = data.aws_iam_policy_document.s3_static_bucket_policy.json
}

data "aws_iam_policy_document" "s3_static_bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.s3_static_bucket.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity_s3.iam_arn]
    }

  }
}


# ==========================================================================================================================
# deploy bucket
# ==========================================================================================================================

# auto scalingにおいて必要なアプリケーションのソースコードを配置するための、privateなバケット
resource "aws_s3_bucket" "s3_deploy_bucket" {
  # バケット名
  bucket = "${lower(var.project)}-${lower(var.environment)}-deploy-${random_string.s3_unique_key.result}"

}

resource "aws_s3_bucket_public_access_block" "s3_deploy_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_deploy_bucket.bucket

  # 「パブリックアクセスOKだよ」というACLの追加をブロックする
  block_public_acls = true

  # 「パブリックアクセスOKだよ」というACLが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  ignore_public_acls = true

  # 「パブリックアクセスOKだよ」というpolicyの追加をブロックする
  block_public_policy = true

  # 「パブリックアクセスOKだよ」というpolicyが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_deploy_bucket_policy" {
  bucket = aws_s3_bucket.s3_deploy_bucket.bucket
  policy = data.aws_iam_policy_document.s3_deploy_bucket_policy.json
}

data "aws_iam_policy_document" "s3_deploy_bucket_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.s3_deploy_bucket.bucket}/*"]
    principals {
      # application serverを展開するec2インスタンスに付与するロール（これはinstance profileでない点に注意）
      type        = "AWS"
      identifiers = [aws_iam_role.application_server_iam_role.arn]
    }
  }
}
