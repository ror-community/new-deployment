// TODO bring under Terraform control
// resource "aws_iam_service_linked_role" "es" {
//   aws_service_name = "es.amazonaws.com"
// }

resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name           = "elasticsearch"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type = "m4.large.elasticsearch"
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
    Domain = "elasticsearch"
  }
}

resource "aws_elasticsearch_domain_policy" "ror" {
  domain_name = aws_elasticsearch_domain.elasticsearch.domain_name

  access_policies = file("elasticsearch_policy.json")
}

resource "aws_route53_record" "elasticsearch-ror" {
   zone_id = data.aws_route53_zone.internal.zone_id
   name = "elasticsearch.ror.community"
   type = "CNAME"
   ttl = var.ttl
   records = [aws_elasticsearch_domain.elasticsearch.endpoint]
}