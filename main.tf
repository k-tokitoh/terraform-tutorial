terraform {
  required_version = ">=1.9.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }

  # 複数人で開発する際に、集権的にtfstateが同期される必要があるので、S3にtfstateを保存する
  # backendはtfstateの保存場所を意味する
  backend "s3" {
    bucket = "terraform-tutorial-tfstate-bucket"
    # オブジェクトのkey
    key     = "terraform-tutorial.tfstate"
    region  = "us-east-1"
    profile = "private"
  }
}

provider "aws" {
  profile = "private"
  region  = "us-east-1"
}

provider "aws" {
  # ailasを設定することで、以下のようにしてこのregionでresourceを管理できる
  # resource "x" "y" {
  #  provider = aws.tokyo
  # }
  alias = "tokyo"

  profile = "private"
  region  = "ap-northeast-1"
}


variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}


# ==========================================================================================================================
# module test
# ==========================================================================================================================

module "webserver" {
  source = "./modules/nginx_server"

  # モジュールの引数を指定する
  instance_type = "t2.micro"

  # モジュールの戻り値は以下のように参照できる
  # module.webserver.instance_id
}
