locals {
  backend_url = var.backend_url == "" && var.lambda_arn != "" ? (
          join("/", [
          "arn:aws:apigateway:${var.region}:lambda:path",
          "2015-03-31",
          "functions",
          var.lambda_arn,
          "invocations"
          ])
  ) : (
          var.backend_url
  )
}

data "template_file" "api_oas" {
  template = file(var.template_file)

  vars = {
    backend_url = local.backend_url
  }
}

resource "aws_api_gateway_account" "this"{
  cloudwatch_role_arn = var.iam_role_arn
}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_gateway_name
  description = var.api_description
  body        = data.template_file.api_oas.rendered
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  depends_on = [aws_cloudwatch_log_group.this]

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }

  depends_on = [aws_api_gateway_account.this]
}

resource "aws_cloudwatch_log_group" "this" {
  name = join("/", [
    "/${var.project_name}-${var.env_abbrev}",
    "apigateway",
    var.api_gateway_name,
    var.stage_name
  ])
  retention_in_days = 7
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = var.set_lambda_permission && var.lambda_function_name != "" ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}