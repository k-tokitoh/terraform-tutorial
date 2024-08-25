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
# dataとして定義することもできるが、awsが標準で提供しているものであれば、コンソールからarnをコピペすればOK

# policyのアタッチ
# role [1] - [n] policyのアタッチ [n] - [1] policy

# ssm の parameter store から環境変数を読み取れるようにする
resource "aws_iam_role_policy_attachment" "application_server_iam_role_ssm_readonly" {
  role       = aws_iam_role.application_server_iam_role.name
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

resource "aws_iam_user" "multiple_users" {
  count = 3
  name  = "${var.project}-${var.environment}-multipleUsers${count.index}"
}
