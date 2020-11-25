// module "iam_account" {
//   source = "terraform-aws-modules/iam/aws//modules/iam-account"

//   account_alias = "${var.account_alias}"

//   minimum_password_length = "${var.minimum_password_length}"
//   require_numbers         = "${var.require_numbers}"
//   require_symbols         = "${var.require_symbols}"
// }

// resource "aws_iam_role" "iam_for_lambda" {
//   name = "iam_for_lambda"

//   assume_role_policy = <<EOF
// {
//   "Version": "2012-10-17",
//   "Statement": [
//     {
//       "Action": "sts:AssumeRole",
//       "Principal": {
//         "Service": [
//           "lambda.amazonaws.com",
//           "edgelambda.amazonaws.com"
//         ]
//       },
//       "Effect": "Allow",
//       "Sid": ""
//     }
//   ]
// }
// EOF
// }
