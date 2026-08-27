resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "local"
  vpc = var.vpc_id
}
