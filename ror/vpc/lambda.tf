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

resource "aws_lambda_function" "id-not-found-error" {
  provider = aws.use1
  filename = "id-not-found-error.js.zip"
  function_name = "id-not-found-error"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "id-not-found-error.handler"
  runtime = "nodejs14.x"
  source_code_hash = sha256(filebase64("id-not-found-error.js.zip"))
  publish = true
}
