module "alb-staging" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.13.0"
  name                          = "lb-staging"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = {"Environment" = "staging"}
  vpc_id                        = module.vpc.vpc_id
  idle_timeout                  = "240"
}

resource "aws_lb_listener" "alb-http-staging" {
  load_balancer_arn = module.alb-staging.this_lb_arn
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

resource "aws_lb_listener" "alb-staging" {
  load_balancer_arn = module.alb-staging.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror-staging.arn

  default_action {
    target_group_arn = data.aws_lb_target_group.api-staging.id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "redirect_www-staging" {
  listener_arn = aws_lb_listener.alb-staging.arn
  priority = 100

  action {
    type = "redirect"

    redirect {
      host        = "staging.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["www.staging.ror.org"]
    }
  }
}

resource "aws_route53_record" "www-staging" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "www.staging.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-staging.dns_name]
}

