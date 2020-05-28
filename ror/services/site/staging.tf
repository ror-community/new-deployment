resource "aws_s3_bucket" "staging-ror-org-s3" {
  bucket = "staging.ror.org"
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
