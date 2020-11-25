resource "aws_cloudfront_distribution" "site-staging" {
  origin {
    domain_name = data.aws_s3_bucket.site-staging.website_endpoint
    origin_id = "staging.ror.org"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }
  origin {
    domain_name = data.aws_s3_bucket.search.bucket_domain_name
    origin_id   = "search.ror.org"

    // s3_origin_config {
    //   origin_access_identity = aws_cloudfront_origin_access_identity.search_ror_org.cloudfront_access_identity_path
    // }
  }

  tags = {
    site        = "ror"
    environment = "staging"
  }

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "5"
    response_code         = "200"
    response_page_path    = "/404.html"
  }

  aliases             = ["staging.ror.org"]
  default_root_object = "index.html"
  enabled             = "true"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "staging.ror.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # This says to redirect http to https
    viewer_protocol_policy = "redirect-to-https"
    compress               = "true"
    min_ttl                = 0

    # default cache time in seconds.  This is 1 day, meaning CloudFront will only
    # look at your S3 bucket for changes once per day.
    default_ttl            = 86400
    max_ttl                = 2592000

    // lambda_function_association {
    //   event_type   = "origin-request"
    //   lambda_arn   = aws_lambda_function.index-page.qualified_arn
    //   include_body = false
    // }
  }

  ordered_cache_behavior {
    path_pattern     = "search*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "search.ror.org"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    # This says to redirect http to https
    viewer_protocol_policy = "redirect-to-https"
    compress               = "true"
    min_ttl                = 0

    # default cache time in seconds.  This is 1 day, meaning CloudFront will only
    # look at your S3 bucket for changes once per day.
    default_ttl            = 86400
    max_ttl                = 2592000

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.redirect-community.qualified_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern     = "0*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "search.ror.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # This says to redirect http to https
    viewer_protocol_policy = "redirect-to-https"
    compress               = "true"
    min_ttl                = 0

    # default cache time in seconds.  This is 1 day, meaning CloudFront will only
    # look at your S3 bucket for changes once per day.
    default_ttl            = 86400
    max_ttl                = 2592000

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.redirect-community.qualified_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern     = "assets/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "search.ror.org"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # This says to redirect http to https
    viewer_protocol_policy = "redirect-to-https"
    compress               = "true"
    min_ttl                = 0

    # default cache time in seconds.  This is 1 day, meaning CloudFront will only
    # look at your S3 bucket for changes once per day.
    default_ttl            = 86400
    max_ttl                = 2592000
  }

  logging_config {
    include_cookies = false
    bucket          = data.aws_s3_bucket.logs.bucket_domain_name

    prefix = "cf-staging/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

//resource "aws_cloudfront_origin_access_identity" "search_ror_org" {}

resource "aws_route53_record" "site-staging" {
  zone_id = data.aws_route53_zone.public.zone_id
  name = "staging.ror.org"
  type = "A"

  alias {
    name = aws_cloudfront_distribution.site-staging.domain_name
    zone_id = aws_cloudfront_distribution.site-staging.hosted_zone_id 
    evaluate_target_health = true
  }
}
