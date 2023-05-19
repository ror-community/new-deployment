resource "aws_lambda_function" "redirect-index" {
  provider = aws.use1
  filename = "redirect-runner.js.zip"
  function_name = "redirect-index"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "redirect-runner.handler"
  runtime = "nodejs14.x"
  source_code_hash = sha256(filebase64("redirect-runner.js.zip"))
  publish = true
}

resource "aws_lambda_function" "check-id-redirect-index" {
  provider = aws.use1
  filename = "check-id-redirect-index.js.zip"
  function_name = "check-id-redirect-index"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "check-id-redirect-index.handler"
  runtime = "nodejs14.x"
  timeout = "10"
  source_code_hash = sha256(filebase64("check-id-redirect-index.js.zip"))
  publish = true
}
