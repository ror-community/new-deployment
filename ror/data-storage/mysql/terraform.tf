terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }

  required_version = ">= 1.6"

  cloud {
    organization = "ror"

    workspaces {
      name = "ror-data-storage-mysql"
    }
  }
}