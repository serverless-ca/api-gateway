resource "aws_iam_role" "apigw_role" {
  name               = "api-gateway"
  assume_role_policy = templatefile("templates/apigateway_role.json.tpl", {})
}

resource "aws_iam_role_policy" "apigw_role_policy" {
  name   = "api-gateway"
  role   = aws_iam_role.apigw_role.id
  policy = templatefile("templates/apigateway_policy.json.tpl", {})
}