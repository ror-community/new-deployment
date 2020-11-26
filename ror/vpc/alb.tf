module "alb" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "~> v5.0"
  name                          = "lb"
  load_balancer_type            = "application"
  security_groups               = [aws_security_group.lb_sg.id]
  access_logs = {
    bucket                      = aws_s3_bucket.logs.bucket
  }
  subnets                       = module.vpc.public_subnets
  tags                          = map("Environment", "production")
  vpc_id                        = module.vpc.vpc_id
}

resource "aws_s3_bucket" "logs" {
  bucket = "logfiles.ror.community"
  acl    = "private"
  policy = templatefile("s3_write_access.json", {
    bucket_name = "logfiles.ror.community"
  })
  tags = {
      Name = "ror-community"
  }
}

resource "aws_lb_listener" "alb-http-community" {
  load_balancer_arn = module.alb.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = data.aws_lb_target_group.api-community.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = module.alb.this_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ror.arn

  default_action {
    target_group_arn = data.aws_lb_target_group.api-community.id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "redirect_www" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type = "redirect"

    redirect {
      host        = "ror.org"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.ror.org"]
  }
}

resource "aws_route53_record" "www" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "www.ror.org"
    type = "CNAME"
    ttl = var.ttl
    records = [data.aws_lb.alb.dns_name]
}
