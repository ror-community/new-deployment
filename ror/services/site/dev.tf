resource "aws_s3_bucket" "www-dev-ror-community" {
  bucket = "www.dev.ror.community"
  acl = "public-read"
  policy = templatefile("s3_cloudfront.json", {
    bucket_name = "www.dev.ror.community"
  })

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "development"
  }
}
