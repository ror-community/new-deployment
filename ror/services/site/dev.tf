resource "aws_s3_bucket" "dev-ror-community-s3" {
  bucket = "dev.ror.community"
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
