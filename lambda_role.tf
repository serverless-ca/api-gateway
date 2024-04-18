resource "aws_iam_role" "lambda_role" {
  name               = "cloud-api-response"
  assume_role_policy = templatefile("${path.module}/templates/lambda_role.json.tpl", {})
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "cloud-api-response"
  role   = aws_iam_role.lambda_role.id
  policy = templatefile("${path.module}/templates/lambda_policy.json.tpl", {})
}