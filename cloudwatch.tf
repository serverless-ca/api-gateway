resource "aws_cloudwatch_log_group" "apigw_access" {
  name = "api-gateway-access"
}

resource "aws_cloudwatch_log_group" "apigw_execution" {
  name = "api-gateway-execution"
}
