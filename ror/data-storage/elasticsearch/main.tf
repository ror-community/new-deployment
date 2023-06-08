// TODO bring under Terraform control
// resource "aws_iam_service_linked_role" "es" {
//   aws_service_name = "es.amazonaws.com"
// }

resource "aws_elasticsearch_domain" "elasticsearch-v7" {
  domain_name           = "elasticsearch-v7"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "m5.large.elasticsearch"
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
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.es-v7-prod.arn}"
    enabled = true
    log_type = "ES_APPLICATION_LOGS"
  }

  tags = {
    Domain = "elasticsearch-v7"
  }

  depends_on = [aws_cloudwatch_log_group.es-v7-prod]
}

resource "aws_cloudwatch_log_group" "es-v7-prod" {
  name = "es-v7-prod"
}

resource "aws_elasticsearch_domain_policy" "ror-v7" {
  domain_name = aws_elasticsearch_domain.elasticsearch-v7.domain_name
  access_policies = file("elasticsearch_policy.json")
}

resource "aws_route53_record" "elasticsearch-v7-ror" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch-v7.ror.community"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch-v7.endpoint]
}