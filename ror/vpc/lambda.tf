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

resource "aws_lambda_function" "redirect-dev" {
  provider = aws.use1
  filename = "redirect-dev.js.zip"
  function_name = "redirect-dev"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "redirect-dev.handler"
  runtime = "nodejs14.x"
  source_code_hash = sha256(filebase64("redirect-dev.js.zip"))
  publish = true
}
