# ==========================================================================================================================
# VPC
# ==========================================================================================================================

# 2つめのラベルはterraform内で識別するための値
resource "aws_vpc" "vpc" {
  # 192.168.0.0は一般にprivate ip addressの範囲として使われる（public ip addressとしては利用されない）
  # 8*4の32bitのうち、上位20bitがネットワークアドレス、下位12bitがホストアドレス
  # すなわち、このcidrでは2^12=4096個のip addressを利用できる（192.168.0.0 ~ 192.168.15.255）
  # NNNN NNNN . NNNN NNNN . NNNN HHHH . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 xxxx . xxxx xxxx
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


# ==========================================================================================================================
# subnet
# ==========================================================================================================================

resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0001 . xxxx xxxx
  cidr_block = "192.168.1.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-publicSubnet1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1c"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0010 . xxxx xxxx
  cidr_block = "192.168.2.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-publicSubnet1c"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0011 . xxxx xxxx
  cidr_block = "192.168.3.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-privateSubnet1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1c"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0100 . xxxx xxxx
  cidr_block = "192.168.4.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-privateSubnet1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}


# ==========================================================================================================================
# route table
# ==========================================================================================================================

# vpc [1] - [n] route table [1] - [n] subnet
# route talbeは複数のrouteをもつ
# routeは、送信先となるipアドレス（の範囲）と、送信先がその範囲に該当した場合にどこに向けてパケットを送出するかを定めたルールである
# subnetにおいて送信されたパケットは、そのsubnetに関連付けられたroute tableに基づいて、順次routeと照らし合わせ、該当したrouteに規定されたtargetに向けて送出される
# route tableはデフォルトで、紐づいたVPCのcidr blockを送信先ipアドレス範囲とし、local（=VPC自身）をtargetとするrouteを持つ
# つまり、以下のroute tableはデフォルトで以下のrouteを持つ
# 送信先ipアドレス範囲: 192.168.0.0/20, ターゲット: local
# 例えばpublic_subnet_1aには、public_route_tableが紐づけられている
# なので、public_subnet_1a内で送信されたパケットは、public_route_tableに基づいてroutingされる
# 送信先が192.168.2.50であれば、192.168.0.0/20に該当するので、そのパケットはlocal（=このvpc自身）に向けて送出される
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-publicRouteTable"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_route_table_association" "public_route_table_1a" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1a.id
}

resource "aws_route_table_association" "public_route_table_1c" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1c.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-privateRouteTable"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table_association" "private_route_table_1a" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1a.id
}

resource "aws_route_table_association" "private_route_table_1c" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1c.id
}


# ==========================================================================================================================
# internet gateway
# ==========================================================================================================================

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-internetGateway"
    Project = var.project
    Env     = var.environment
  }
}

# public route tableに、インターネットゲートウェイへのルートを追加登録する
resource "aws_route" "route_for_internet_gateway_on_public_route_table" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}


# ==========================================================================================================================
# trial for multiple resource generation
# ==========================================================================================================================

resource "aws_vpc" "multiple_subnet_vpc" {
  cidr_block = "192.168.0.0/20"
}

resource "aws_subnet" "multiple_subnet" {
  for_each = {
    "192.168.1.0/24" = "us-east-1a",
    "192.168.2.0/24" = "us-east-1b",
    "192.168.3.0/24" = "us-east-1c",

  }

  vpc_id            = aws_vpc.multiple_subnet_vpc.id
  cidr_block        = each.key
  availability_zone = each.value
}
