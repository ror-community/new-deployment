terraform {
  required_version = "~> 0.15.5"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ror"
    workspaces {
      name = "ror-services-api-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}
