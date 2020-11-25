resource "aws_s3_bucket" "www-staging-ror-community" {
  bucket = "www.staging.ror.community"
  acl = "public-read"
  policy = templatefile("s3_cloudfront.json", {
    bucket_name = "www.staging.ror.community"
  })

  website {
    index_document = "index.html"
  }

  tags = {
    site        = "ror"
    environment = "staging"
  }
}
