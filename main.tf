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

variable "project" {
  type = string
}

variable "environment" {
  type = string
}
