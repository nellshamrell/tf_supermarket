output "elasticache_url" {
  value = "${aws_elasticache_cluster.supermarket_cluster.cache_nodes.0.address}"
}
