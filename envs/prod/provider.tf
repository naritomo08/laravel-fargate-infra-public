#AWSを今回は使いますという宣言
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Env    = "prod"
      System = "example"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.42.0"
    }
  }

  required_version = "1.1.3"
}
