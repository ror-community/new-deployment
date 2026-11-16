terraform {
  required_version = "~> 0.13.7"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ror"
    workspaces {
      name = "ror-services-api-prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}
