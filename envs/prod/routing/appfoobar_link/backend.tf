# ftstateをバケットに保管する。
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    region  = "ap-northeast-1"
    key     = "example/prod/routing/appfoobar_link_v1.0.0.tfstate"
    encrypt = true
    dynamodb_table = "terraform_state_lock"
  }
}
