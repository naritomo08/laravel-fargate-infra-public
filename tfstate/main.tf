provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state" #適当なユニークの名前に変えてください
  force_destroy = true
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }

  required_version = "1.1.3"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_dynamo" {
  name           = "terraform_state_lock" #適当なユニークの名前に変えてください
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}