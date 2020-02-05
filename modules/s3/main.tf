# TODO: Move policy document to the templates directory, and properly template it.
# TODO: Move cloudtrail setup to its own module.

data "aws_caller_identity" "current" {}
# data "template_file" "policy_document" {
#   template = "${file("templates/s3_policy_document.tpl")}"
# }

resource "aws_s3_bucket" "selected" {
  bucket = "${var.bucket_name}"
  tags = {
    Name = "${var.bucket_name}"
    Company = "${var.company}"
    Environment = "${var.env}"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${var.bucket_name}"

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
