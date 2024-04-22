resource "aws_api_gateway_account" "server" {
  cloudwatch_role_arn = aws_iam_role.apigw_role.arn
}