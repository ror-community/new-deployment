resource "aws_elasticsearch_domain" "elasticsearch-dev" {
  domain_name           = "elasticsearch-dev"
  elasticsearch_version = "6.8"

  cluster_config {
    instance_type = "m4.large.elasticsearch"
    instance_count = 2
    zone_awareness_enabled = true
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
      volume_size = 50
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.private_security_group.id]
    subnet_ids = var.private_subnet_ids
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es-dev.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = "elasticsearch-dev"
  }
}

resource "aws_cloudwatch_log_resource_policy" "es-dev-log-policy" {
  policy_name     = "es-dev-log-policy"
  policy_document = file("elasticsearch_logs_policy.json")
}

resource "aws_cloudwatch_log_group" "es-dev" {
  name = "/es/dev"
}

resource "aws_route53_record" "elasticsearch-dev" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.dev.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-dev.endpoint]
}