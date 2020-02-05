# TODO: Move policy document to the templates directory, and properly template it.

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "b" {
  bucket = "${data.aws_caller_identity.current.account_id}-cloudtrail"
  tags = {
    Name = "${var.company}-${var.env}-cloudtrail"
    Environment = "${var.env}"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${data.aws_caller_identity.current.account_id}-cloudtrail"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-cloudtrail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "web" {
  name                          = "${var.company}-${var.app}-ct"
  s3_bucket_name                =  "${data.aws_caller_identity.current.account_id}-cloudtrail"
  include_global_service_events = false
}

