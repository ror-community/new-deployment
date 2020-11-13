provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  version    = "~> 2.7"
}

provider "aws" {
  # us-east-1 region
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
  alias = "use1"
}

data "template_file" "search" {
  template = file("s3_cloudfront.json")

  vars = {
    bucket_name = "search.ror.community"
  }
}

data "template_file" "search-dev" {
  template = file("s3_cloudfront.json")

  vars = {
    bucket_name = "search.dev.ror.community"
  }
}

