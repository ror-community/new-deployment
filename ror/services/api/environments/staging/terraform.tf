terraform {
  required_version = "~> 1.16"

  cloud {
    organization = "ror"
    workspaces {
      name = "ror-services-api-staging"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}
