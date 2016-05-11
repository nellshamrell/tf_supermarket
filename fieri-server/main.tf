provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "fieri-server" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "fieri-server"
  }
  security_groups = ["${split(",", var.security_groups)}"]
  key_name = "${var.key_name}"
}
