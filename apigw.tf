resource "aws_api_gateway_account" "server" {
  cloudwatch_role_arn = aws_iam_role.apigw_role.arn
}

resource "aws_api_gateway_stage" "server" {
  deployment_id = aws_api_gateway_deployment.server.id
  rest_api_id   = aws_api_gateway_rest_api.server.id
  stage_name    = "dev"
  description   = "API Gateway"

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_access.arn
    format = jsonencode(
      {
        errorResponseType = "$context.error.responseType"
        errorMessage      = "$context.error.message"
        certPEM           = "$context.identity.clientCert.clientCertPem"
        certSubjectDN     = "$context.identity.clientCert.subjectDN"
        certIssuerDN      = "$context.identity.clientCert.issuerDN"
        certSerialNumber  = "$context.identity.clientCert.serialNumber"
        certNotBefore     = "$context.identity.clientCert.validity.notBefore"
        certNotAfter      = "$context.identity.clientCert.validity.notAfter"
        extendedRequestId = "$context.extendedRequestId"
        httpMethod        = "$context.httpMethod"
        integrationError  = "$context.integrationErrorMessage"
        integrationStatus = "$context.integration.integrationStatus"
        ip                = "$context.identity.sourceIp"
        protocol          = "$context.protocol"
        requestId         = "$context.requestId"
        requestTime       = "$context.requestTime"
        routeKey          = "$context.routeKey"
        status            = "$context.status"
    })
  }
  depends_on = [aws_api_gateway_account.server]
}

resource "aws_api_gateway_deployment" "server" {
  rest_api_id = aws_api_gateway_rest_api.server.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api.id,
      aws_api_gateway_method.api.id,
      aws_api_gateway_integration.api.id,
      aws_lambda_permission.apigw_lambda_api.function_name
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_rest_api" "server" {
  name        = "cloud-app-api"
  description = "Cloud App API"

  # argument below must have value true to prevent bypass of mutual TLS
  disable_execute_api_endpoint = false

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method_settings" "server" {
  rest_api_id = aws_api_gateway_rest_api.server.id
  stage_name  = aws_api_gateway_stage.server.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    data_trace_enabled     = false
    logging_level          = "INFO"
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

## begin POST /api
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.server.id
  parent_id   = aws_api_gateway_rest_api.server.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "api" {
  rest_api_id   = aws_api_gateway_rest_api.server.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.server.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.api.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_response.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_response.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.server.id}/*/${aws_api_gateway_method.api.http_method}${aws_api_gateway_resource.api.path}"
}
