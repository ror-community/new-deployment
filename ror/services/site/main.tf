resource "aws_s3_bucket" "www-ror-community" {
  bucket = "www.ror.community"
  acl = "public-read"
  policy = templatefile("s3_cloudfront.json", {
    bucket_name = "www.ror.community"
  })

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "production"
  }
}
