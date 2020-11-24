resource "aws_s3_bucket" "www-ror-community" {
  bucket = "www.ror.community"
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
