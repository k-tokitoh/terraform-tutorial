# !!!!!! 本体とは無関係のiam周りの練習です !!!!!!
# ==========================================================================================================================
# policy
# ==========================================================================================================================

# 請求周りの操作はできない
resource "aws_iam_policy" "billing_deny" {
  name        = "${var.project}-${var.environment}-iamPolicyBillingDeny"
  description = "Deny billing access"
  policy      = data.aws_iam_policy_document.billing_deny.json
}


data "aws_iam_policy_document" "billing_deny" {
  statement {
    effect    = "Deny"
    actions   = ["aws-portal:*"]
    resources = ["*"]
  }
}

# ec2の再起動ができる
resource "aws_iam_policy" "ec2_rebootable" {
  name        = "${var.project}-${var.environment}-iamPolicyRebootEC2"
  description = "Allow rebooting EC2"
  policy      = data.aws_iam_policy_document.ec2_rebootable.json
}


data "aws_iam_policy_document" "ec2_rebootable" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:RebootInstances"]
    resources = ["*"]
  }
}

# 自身のパスワードを変更できる
resource "aws_iam_policy" "change_own_password" {
  name        = "${var.project}-${var.environment}-iamPolicyChangeOwnPassword"
  description = "Allow changing own password"
  policy      = data.aws_iam_policy_document.change_own_password.json
}


data "aws_iam_policy_document" "change_own_password" {
  statement {
    effect    = "Allow"
    actions   = ["iam:ChangePassword"]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }
}


# ==========================================================================================================================
# group
# ==========================================================================================================================

# groupにpolicyをアタッチする方法は以下2つ
# 1.
#   group(resource block) [1] - [n] group policy attachment(resource block) [n] - [1] policy(resource block)
# 2.
#   group(resource block) [1] - [n] group policy(resource block) [n] - [1] policy document(data block)
#   こちらの場合はgroupがインラインポリシーをもつ。ポリシーというリソースはクラウド上には発生しない

resource "aws_iam_group" "developers" {
  name = "${var.project}-${var.environment}-developers"
}

resource "aws_iam_group_policy_attachment" "policy_developers_readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "policy_developers_deny_billing" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.billing_deny.arn
}

resource "aws_iam_group_policy_attachment" "policy_developers_reboot_ec2" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.ec2_rebootable.arn
}

resource "aws_iam_group_policy_attachment" "policy_developers_change_own_password" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.change_own_password.arn
}
