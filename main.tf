provider "aws"{
  region = "ap-northeast-2"
}

terraform {
  backend "s3" {
    bucket = "do-not-delete-terraform-state-sot"
    key = "terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "do-not-delete-terraform-state-lock"
    acl = "bucket-owner-full-control"
  }
}