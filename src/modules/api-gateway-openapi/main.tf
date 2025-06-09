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
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}