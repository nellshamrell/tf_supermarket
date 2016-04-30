provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "template_file" "bucket_acl" {
  template = "${file("${path.module}/templates/bucket_acl.tpl")}"
  vars {
    bucket_name = "${var.bucket_name}"
    acl = "${var.bucket_acl}"
    policy = "${var.region}"
    aws_iam_username = "${var.aws_iam_username}"
  }
}

resource "aws_s3_bucket" "supermarket-bucket" {
  bucket = "${var.bucket_name}"
  acl = "${var.bucket_acl}"
  region = "${var.region}"
  policy = "${template_file.bucket_acl.rendered}"
}
