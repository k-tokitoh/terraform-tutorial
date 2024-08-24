https://www.udemy.com/course/iac-with-terraform/

# prerequisites

- `brew install tfenv`
- `tfenv list-remote` or `tfenv list`
- `tfenv install x.x.x`
- `tfenv use x.x.x`

# 構成

### 概要

<img src="images/structure-summary.png" width="800px">

### 詳細

<img src="images/structure-details.png" width="800px">

# cli commands

- 適用
  - `terraform apply`
- 削除
  - `terraform destroy`
- リソース一覧
  - `terraform state list`
- リソース詳細
  - `terraform state show <ADDRESS>`
  - <ADDRESS>はリソース一覧で表示される文字列
- リソース名の変更
  - `terraform state mv <SRC_ADDRESS> <DST_ADDRESS>`
  - 上記コマンドにより tfstate でのリソース名が更新される（tf ファイルで別途リソース名を更新する必要がある点に注意する）
- tfstate にリソースを取り込む
  - `terraform import <ADDRESS> <ID>`
  - ex. `terraform import aws_instance.imported i-00000000000`
- リソースを tf 管理対象外にする = tfstate から削除する
  - `terraform state rm <ADDRESS>`
- 実際のクラウド上の状態を tfstate に反映する
  - `terraform refresh`
