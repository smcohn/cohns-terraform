provider "aws" {
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  region                  = "us-west-2"
  shared_credentials_file = "/home/smcohn/.aws/credentials"
  profile                 = "cohns"
}
