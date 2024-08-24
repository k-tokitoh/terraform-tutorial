# s3は https://sample-bucket.s3-us-east-1.amazonaws.com/ のようなドメイン名をもつ
# これに対して割り当てられるipアドレスは複数存在する
# それらのipアドレスをまとめて指示できるのがprefix list
# s3やdynamodbについては、aws側が自動的にprefix listを提供している
# これはterraformで作成/削除するリソースではないので、dataブロックで扱う
data "aws_prefix_list" "s3_prefix_list" {
  name = "com.amazonaws.*.s3"
}
