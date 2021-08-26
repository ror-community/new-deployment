// manage requests to ror.community
module "alb-community" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.13.0"
  name                          = "lb-community"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = map("Environment", "production")
  vpc_id                        = module.vpc.vpc_id
}

resource "aws_lb_listener" "alb-http-community" {
  load_balancer_arn = module.alb-community.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "ror.community"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

resource "aws_lb_listener" "alb-community" {
  load_balancer_arn = module.alb-community.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The domain ror.community has been retired, please use ror.org."
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "apex-ror-community" {
  zone_id = aws_route53_zone.public-community.zone_id
  name    = "ror.community"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb-community.dns_name
    zone_id                = data.aws_lb.alb-community.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www-ror-community" {
  zone_id = aws_route53_zone.public-community.zone_id
  name = "www.ror.community"
  type = "A"

  alias {
    name = data.aws_lb.alb-community.dns_name
    zone_id = data.aws_lb.alb-community.zone_id
    evaluate_target_health = true
  }
}
