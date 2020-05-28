resource "aws_s3_bucket" "dev-ror-org-s3" {
  bucket = "dev.ror.org"
  acl = "public-read"
  policy = data.template_file.site-dev.rendered

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "development"
  }
}
