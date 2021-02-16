module "alb-dev" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "~> v5.0"
  name                          = "lb-dev"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = map("Environment", "dev")
  vpc_id                        = module.vpc.vpc_id
}

resource "aws_lb_listener" "alb-http-dev" {
  load_balancer_arn = module.alb-dev.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"  

    redirect {
      host        = "dev.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

resource "aws_lb_listener" "alb-dev" {
  load_balancer_arn = module.alb-dev.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror.arn

  default_action {
    target_group_arn = data.aws_lb_target_group.api-dev.id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "redirect_www-dev" {
  listener_arn = aws_lb_listener.alb-dev.arn

  action {
    type = "redirect"

    redirect {
      host        = "www.dev.ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.dev.ror.org"]
  }
}

resource "aws_route53_record" "www-dev" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "www.dev.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb-dev.dns_name]
}
