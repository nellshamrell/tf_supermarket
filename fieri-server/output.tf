output "public_ip" {
  value = "${aws_instance.fieri-server.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.fieri-server.public_dns}"
}
