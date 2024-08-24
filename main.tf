terraform {
  required_version = ">=1.9.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
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
