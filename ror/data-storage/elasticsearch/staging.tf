resource "aws_elasticsearch_domain" "elasticsearch-staging" {
  domain_name           = "elasticsearch-staging"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type = "t3.small.elasticsearch"
    instance_count = 1
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options{
      ebs_enabled = true
      volume_type = "gp2"
      volume_size = 100
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.private_security_group.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  tags = {
    Domain = "elasticsearch-staging"
  }
}

resource "aws_route53_record" "elasticsearch-staging" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.staging.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-staging.endpoint]
}