resource "aws_s3_bucket" "www-dev-ror-community" {
  bucket = "www.dev.ror.community"
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
