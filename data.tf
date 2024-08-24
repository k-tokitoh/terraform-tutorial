# s3は https://sample-bucket.s3-us-east-1.amazonaws.com/ のようなドメイン名をもつ
# これに対して割り当てられるipアドレスは複数存在する
# それらのipアドレスをまとめて指示できるのがprefix list
# s3やdynamodbについては、aws側が自動的にprefix listを提供している
# これはterraformで作成/削除するリソースではないので、dataブロックで扱う
data "aws_prefix_list" "s3_prefix_list" {
  name = "com.amazonaws.*.s3"
}


data "aws_ami" "application_ami" {
  # 検索した結果複数のamiがhitした場合に、最新のものを選択する
  most_recent = true

  # 自身が登録したamiと、amazon公式のamiを検索対象とする
  owners = ["self", "amazon"]

  # 以下の手順により値を決定している
  # - マネジメントコンソールでイメージをみつける
  # - 以下のコマンドで、上記のイメージの情報を取得する
  #   - aws ec2 --profile private describe-images --image-ids ami-00000000000
  filter {
    name = "name"
    # * は日付部分
    values = ["al2023-ami-2023.5.*.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}
