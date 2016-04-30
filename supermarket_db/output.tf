output "database_host" {
  value = "${aws_db_instance.supermarket-db.endpoint}"
}

output "database_port" {
  value = "${aws_db_instance.supermarket-db.port}"
}
