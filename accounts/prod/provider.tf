provider "aws" {
  region                      = "us-west-2"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  shared_credentials_file = "/home/smcohn/.aws/credentials"
  profile                 = "cohns"
  assume_role {
    role_arn     = "arn:aws:iam::069717985088:role/cohns-prod-admin-role"
    session_name = "cohns-prod-admin-session"
  }

}
