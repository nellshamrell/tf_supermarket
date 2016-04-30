output "public_ip" {
  value = "${aws_instance.supermarket-server.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.supermarket-server.public_dns}"
}
