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
  function_name      = aws_lambda_function.redirect-curation-request.function_name
  authorization_type = "NONE"
  role = data.aws_iam_role.iam_for_lambda.arn
}

resource "aws_cloudfront_distribution" "curation-request" {
  origin {
    domain_name = aws_lambda_function_url.redirect-curation-request-url.function_url
    origin_id   = "curation-request.ror.org"
  }

  enabled             = true
  is_ipv6_enabled     = true

  aliases = ["curation-request.ror.org"]

  default_cache_behavior {
    allowed_methods  = ["GET"]
    cached_methods   = ["GET"]
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