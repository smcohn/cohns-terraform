terraform {
  backend "s3" {
    bucket = "069717985088-terraform"
    region = "us-west-2"
    key = "state"
  }
}
provider "aws" {
  region  = "us-west-2"
  assume_role {
    role_arn     = "role_arn = arn:aws:iam::451089431772:role/cohns-prod-admin-role"
    session_name = "cohns-prod"
  }
  profile = "cohns-prod"
  alias   = "cohns-prod"
}

