provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "supermarket-server" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "supermarket-server"
  }
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${split(",", var.vpc_security_group_ids)}"]
  key_name = "${var.key_name}"
}
