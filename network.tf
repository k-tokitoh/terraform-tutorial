# 2つめのラベルはterraform内で識別するための値
resource "aws_vpc" "vpc" {
  # 192.168.0.0は一般にprivate ip addressの範囲として使われる（public ip addressとしては利用されない）
  # 8*4の32bitのうち、上位20bitがネットワークアドレス、下位12bitがホストアドレス
  # すなわち、このcidrでは2^12=4096個のip addressを利用できる（192.168.0.0 ~ 192.168.15.255）
  cidr_block = "192.168.0.0/20"

  # このvpc内で起動するec2インスタンスをどう配置するか
  # - default: 共有ハードウェアを利用する
  # - dedicated: 自身のAWSアカウントのみから利用されるよう、ハードウェアを専有する。どの物理ホストかは指定しない
  # - host: 特定の専有された物理ホストにインスタンスを配置する
  instance_tenancy = "default"

  # DNSサポートが有効だと、そのVPC内のec2インスタンスやその他のリソースが、DNSクエリを解決できるようになる。
  # つまり、ec2インスタンスなどから他のリソースに対してドメイン名に基づくアクセスが可能になる
  enable_dns_support = true

  # そのVPC内のec2インスタンスに対して、DNSホスト名を割り当てるかどうか
  enable_dns_hostnames = true

  # このVPC内で新しいIPv6 CIDRブロックを生成して、そのCIDRブロックをVPCに割り当てるかどうか
  # 割り当てた場合には、そのVPC内のインスタンスにはIPv6アドレスが割り当てられることになる
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment
  }
}
