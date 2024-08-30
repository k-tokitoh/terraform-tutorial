# ==========================================================================================================================
# iam role
# ==========================================================================================================================

# ロールとec2インスタンスが紐づくのではなく、インスタンスプロファイルというものがひとつ介在する
# 基本的にはロールと同じもの、と考えてOK
resource "aws_iam_instance_profile" "application_instance_profile" {
  # ロールの指定
  role = aws_iam_role.application_server_iam_role.name

  # nameはオプショナルではあるが、わかりやすさのためroleと同じ値を指定しておくとよい
  name = aws_iam_role.application_server_iam_role.name
}

# ロール本体
resource "aws_iam_role" "application_server_iam_role" {
  name               = "${var.project}-${var.environment}-applicationServerIamRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 信頼ポリシー
# そのrole = 帽子をどういう人なら被っていいか、を定める
# 信頼policy [1] - [n] role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      # ユーザーではなくリソースがロールを引き受ける場合は"Service"を指定する
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# policy
# そのrole = 帽子を被っていたら何ができるか、を定める

# policyの書き方いろいろ
# see:  https://dev.classmethod.jp/articles/writing-iam-policy-with-terraform/
#
# 1
# resource "aws_iam_policy" "xx" {
#   policy = file("./xx.json")
# }
# 
# 2
# resource "aws_iam_policy" "xx" {
#   policy = templatefile(
#     "./xx.json",
#     { xx = xx },
#   )
# }
# 
# 3
# resource "aws_iam_policy" "xx" {
#   policy = <<EOS
# {
#   "xx": "${xx}"
# }
# EOS
# }
# 
# 4
# resource "aws_iam_policy" "xx" {
#   policy = jsonencode({
#     "xx" = xx
#   })
# }
# 
# 5
# resource "aws_iam_policy" "xx" {
#   policy = data.aws_iam_policy_document.xx.json
# }
# data "aws_iam_policy_document" "xx" {
#   statement {
#     xx = xx
#   }
# }


# policyのアタッチ
# role [1] - [n] policyのアタッチ [n] - [1] policy

# ssm の parameter store から環境変数を読み取れるようにする
resource "aws_iam_role_policy_attachment" "application_server_iam_role_ssm_readonly" {
  role = aws_iam_role.application_server_iam_role.name
  # aws管理ポリシーは、コンソールからarnをコピペすればOK
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# s3のreadonlyアクセス権限を付与
resource "aws_iam_role_policy_attachment" "application_server_iam_role_s3_readonly" {
  role       = aws_iam_role.application_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# DBの認証情報をssm parameter storeから取得するにあたってEC2のタグの情報が必要らしい。よくわかってない。
resource "aws_iam_role_policy_attachment" "application_server_iam_role_ec2_readonly" {
  role       = aws_iam_role.application_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# RDSへの接続においてはssmのparameters storeに格納した情報でmysql認証を行うため、ロール（による認証）は不要
# mysql認証ではなくIAMロールによる認証を選択することも2017年から可能になっているが、複雑なためメジャーではない


# ==========================================================================================================================
# trial for multiple resource generation (count)
# ==========================================================================================================================

# 複数リソースの作成とは関係ない話だが、userのパスワードを得るには、安全に通信するためにpgpというのを利用する必要がある
# 手元でキーペアをつくり、公開鍵を渡して、暗号化したものが返ってくるので、手元の秘密鍵で複合するという流れ
resource "aws_iam_user" "multiple_users" {
  count = 3
  name  = "${var.project}-${var.environment}-multipleUsers${count.index}"
}
