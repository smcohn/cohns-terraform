terraform {
   backend "s3" {
     bucket = "451089431772-terraform"
     key    = "state"
     region = "us-west-2"
   }
 }
#terraform {
#  required_version = "0.12.13"
#}

provider "aws" {
  region  = "us-west-2"
  assume_role {
    role_arn     = "role_arn = arn:aws:iam::451089431772:role/cohns-dev-admin-role"
    session_name = "cohns-dev"
  }
  profile = "cohns"
  alias   = "cohns-dev"
}

