resource "aws_s3_bucket" "ror-org-s3" {
  bucket = "ror.org"
  acl = "public-read"
  policy = data.template_file.site.rendered

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "production"
  }
}
