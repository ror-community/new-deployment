resource "aws_lambda_function" "redirect-curation-request" {
  provider = aws.use1

  filename = "curation-request-redirect.js.zip"
  function_name = "redirect-curation-request"
  role = data.aws_iam_role.iam_for_lambda.arn
  handler = "curation-request-redirect.handler"
  runtime = "nodejs12.x"
  source_code_hash = sha256(filebase64("curation-request-redirect.js.zip"))
  publish = true
}

resource "aws_lambda_function_url" "redirect-curation-request-url" {
  provider = aws.use1
  function_name      = aws_lambda_function.redirect-curation-request.arn
  authorization_type = "NONE"
}

resource "aws_cloudfront_distribution" "curation-request" {
  origin {
    domain_name = "${trimsuffix(trimprefix(aws_lambda_function_url.redirect-curation-request-url.function_url, "https://"), "/")}"
    origin_id   = "curation-request.ror.org"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true

  aliases = ["curation-request.ror.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "curation-request.ror.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_route53_record" "curation-request" {
   zone_id = data.aws_route53_zone.ror.zone_id
   name = "curation-request.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = ["${aws_cloudfront_distribution.curation-request.domain_name}"]
}

resource "aws_wafregional_web_acl" "default" {
  name        = "default"
  metric_name = "default"

  default_action {
    type = "ALLOW"
  }

  rule {
    name     = "AWS-AWSManagedRulesBotControlRuleSet"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWS-AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blocked-bot"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "blocked-requests"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafregional_web_acl_association" "curation-request-acl" {
  resource_arn = aws_cloudfront_distribution.curation-request.arn
  web_acl_id   = aws_wafregional_web_acl.default.id
}