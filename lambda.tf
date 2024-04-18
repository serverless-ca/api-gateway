data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_code/response.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "api_response" {
  filename      = "lambda_function_payload.zip"
  function_name = "api-response"
  role          = aws_iam_role.lambda_role.arn
  handler       = "response.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
}