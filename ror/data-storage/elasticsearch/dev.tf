resource "aws_elasticsearch_domain" "elasticsearch-dev" {
  domain_name           = "elasticsearch-dev"
  elasticsearch_version = "6.8"

  cluster_config {
    instance_type = "t3.medium.elasticsearch"
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
      volume_size = 50
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.private_security_group.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.es-dev.arn}"
    enabled = true
    log_type = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = "elasticsearch-dev"
  }
  depends_on = [aws_cloudwatch_log_group.es-dev]
}

resource "aws_cloudwatch_log_resource_policy" "es-dev-log-policy" {
  policy_name     = "es-dev-log-policy"
  policy_document = file("elasticsearch_logs_policy.json")
}

resource "aws_cloudwatch_log_group" "es-dev" {
  name = "es-dev"
}

resource "aws_route53_record" "elasticsearch-dev" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.dev.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-dev.endpoint]
}

resource "aws_elasticsearch_domain" "elasticsearch-v7-dev" {
  domain_name           = "elasticsearch-v7-dev"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "t3.medium.elasticsearch"
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
      volume_size = 50
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.private_security_group.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.es-v7-dev.arn}"
    enabled = true
    log_type = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = "elasticsearch-v7-dev"
  }
  depends_on = [aws_cloudwatch_log_group.es-v7-dev]
}

resource "aws_cloudwatch_log_group" "es-dev" {
  name = "es-v7-dev"
}

resource "aws_route53_record" "elasticsearch-v7-dev" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch-v7.dev.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-v7-dev.endpoint]
}