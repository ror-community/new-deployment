module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  single_nat_gateway = true
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = false

  tags = {
    Terraform = "true"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "load-balancer-sg"
  description = "Allow all inbound traffic to http and https"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    from_port    = 443
    to_port      = 443
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "load-balancer-sg"
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "fargate-ecs-service-sg"
  description = "Allow all inbound traffic to service port"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fargate-ecs-service-sg"
  }
}
