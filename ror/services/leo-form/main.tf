resource "aws_s3_bucket" "leo" {
  bucket = "leo.ror.org"
  acl = "public-read"
  policy = templatefile("s3_cloudfront.json", {
    bucket_name = "leo.ror.org"
  })

  website {
    index_document = "index.html"
  }

  tags = {
    Name = "leoform"
  }
}


resource "aws_cloudfront_distribution" "leo" {
  origin {
    domain_name = aws_s3_bucket.leo.bucket_domain_name
    origin_id   = "leo.ror.org"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["leo.ror.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "leo.ror.org"

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

resource "aws_route53_record" "leo" {
   zone_id = data.aws_route53_zone.ror.zone_id
   name = "leo.ror.org"
   type = "CNAME"
   ttl = var.ttl
   records = ["${aws_cloudfront_distribution.leo.domain_name}"]
}