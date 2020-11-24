resource "aws_s3_bucket" "www-staging-ror-community" {
  bucket = "www.staging.ror.community"
  acl = "public-read"
  policy = data.template_file.site-staging.rendered

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "staging"
  }
}
