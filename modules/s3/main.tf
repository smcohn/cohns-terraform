# TODO: Move policy document to the templates directory, and properly template it.

# data "template_file" "policy_document" {
#   template = "${file("templates/s3_policy_document.tpl")}"
# }

resource "aws_s3_bucket" "selected" {
  bucket         = "${var.bucket_name}"

  tags = {
    Name         = "${var.bucket_name}"
    Company      = "${var.company}"
    Environment  = "${var.env}"
  }
}

# resource "aws_s3_bucket_policy" "selected" {
#   bucket = "${var.bucket_name}"
# 
# }
