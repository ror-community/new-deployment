module "alb-dev" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.13.0"
  name                          = "lb-dev"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = {"environment" = "ror-dev"}
  vpc_id                        = module.vpc.vpc_id
  idle_timeout                  = "240"
}

resource "aws_lb_listener" "alb-http-dev" {
  load_balancer_arn = module.alb-dev.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb-dev" {
  load_balancer_arn = module.alb-dev.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror.arn

  # Mutual authentication with client certificate
  mutual_authentication {
    mode                             = "verify"
    trust_store_arn                 = aws_lb_trust_store.api_gateway_trust_store.arn
    ignore_client_certificate_expiry = false
  }

  default_action {
    target_group_arn = data.aws_lb_target_group.api-dev.id
    type             = "forward"
  }
}


# Trust store for API Gateway client certificate
resource "aws_lb_trust_store" "api_gateway_trust_store" {
  name = "ror-api-gateway-trust-store-dev"
  
  ca_certificates_bundle_s3_bucket = data.aws_s3_bucket.cert_store.bucket
  ca_certificates_bundle_s3_key    = data.aws_s3_object.api_gateway_cert.key
}

# Reference to existing S3 bucket with certificate
data "aws_s3_bucket" "cert_store" {
  bucket = "ror-dev-trust-store"
}

# Reference to existing certificate file
data "aws_s3_object" "api_gateway_cert" {
  bucket = data.aws_s3_bucket.cert_store.bucket
  key    = "dev.cert"
}

resource "aws_lb_listener_rule" "redirect_www-dev" {
  listener_arn = aws_lb_listener.alb-dev.arn
  priority = 100

  action {
    type = "redirect"

    redirect {
      host        = "dev.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["www.dev.ror.org"]
    }
  }
}

resource "aws_route53_record" "www-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "www.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-dev.dns_name]
}

# HTTP listener rule to handle API Gateway requests (higher priority than default redirect)
resource "aws_lb_listener_rule" "api-dev-http-forward" {
  listener_arn = aws_lb_listener.alb-http-dev.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api-dev.arn
  }

  condition {
    host_header {
      values = ["api.dev.ror.org"]
    }
  }
}
