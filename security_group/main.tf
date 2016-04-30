provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# Create security group for servers in this cluster
resource "aws_security_group" "allow-ssh-443" {
  name = "allow-ssh-443"
  tags {
    Name = "Allow SSH 443"
  }
}

resource "aws_security_group_rule" "allow-ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.allow-ssh-443.id}"
}

resource "aws_security_group_rule" "allow-443" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.allow-ssh-443.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.allow-ssh-443.id}"
}
