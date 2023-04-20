resource "aws_elasticsearch_domain" "elasticsearch-staging" {
  domain_name           = "elasticsearch-staging"
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
      volume_size = 100
  }

  vpc_options {
    security_group_ids = [data.aws_security_group.private_security_group.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.es-staging.arn}"
    enabled = true
    log_type = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = "elasticsearch-staging"
  }

  depends_on = [aws_cloudwatch_log_group.es-staging]
}

resource "aws_cloudwatch_log_group" "es-staging" {
  name = "es-staging"
}

resource "aws_route53_record" "elasticsearch-staging" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.staging.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-staging.endpoint]
}

resource "aws_elasticsearch_domain" "elasticsearch-v7-staging" {
  domain_name           = "elasticsearch-v7-staging"
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
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.es-v7-staging.arn}"
    enabled = true
    log_type = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = "elasticsearch-v7-staging"
  }
  depends_on = [aws_cloudwatch_log_group.es-v7-staging]
}

resource "aws_cloudwatch_log_group" "es-v7-staging" {
  name = "es-v7-staging"
}

resource "aws_route53_record" "elasticsearch-v7-staging" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch-v7.staging.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-v7-staging.endpoint]
}