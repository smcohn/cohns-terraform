# terraform {
#   backend "s3" {
#     bucket = "cohns-terraform-state"
#     key    = "dev"
#     region = "us-east-1"
#   }
# }
provider "aws" {
  region  = "us-west-2"
  assume_role {
    role_arn     = "role_arn = arn:aws:iam::451089431772:role/cohns-dev-admin-role"
    session_name = "cohns-dev"
  }
  profile = "cohns-dev"
  alias   = "cohns-dev"
}

