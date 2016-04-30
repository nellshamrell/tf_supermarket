provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_elasticache_cluster" "supermarket_cluster" {
  cluster_id = "${var.cache_cluster_name}"
  engine = "${var.cache_cluster_engine}"
  node_type = "${var.cache_cluster_node_type}"
  port = "${var.cache_cluster_port}"
  num_cache_nodes = "${var.cache_cluster_num_nodes}"
  parameter_group_name = "${var.cache_parameter_group_name}"
}
