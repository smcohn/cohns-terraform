provider "aws" {
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  region                  = "us-west-2"
  shared_credentials_file = "/Users/smcohn/.aws/credentials"
  profile                 = "default"
  assume_role {
    role_arn     = "arn:aws:iam::451089431772:role/cohns-dev-admin-role"
    session_name = "cohns-dev-admin-session"
  }
}
