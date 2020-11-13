resource "aws_s3_bucket" "ror-community-s3" {
  bucket = "ror.community"
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
