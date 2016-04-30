provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_db_instance" "supermarket-db" {
  allocated_storage = "${var.db_allocated_storage}"
  engine = "${var.db_engine}"
  engine_version = "${var.db_engine_version}"
  instance_class = "${var.db_instance_class}"
  identifier = "${var.db_identifier}"
  name = "${var.db_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
}
