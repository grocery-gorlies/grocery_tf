locals {
  basic_tags = {
    region      = var.region,
    environment = var.env_abbrev,
    project     = var.project_name
  }
}


data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda" {
  count = var.create_role ? 1 : 0

  name               = "${var.function_name}-lambda-iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge({
    resource = "iam"
  },
    var.tags,
    local.basic_tags
  )
}


resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_cloudwatch_log_group" "lambda" {
  name = join("/", [
    "/lambda",
    var.region,
    "${var.project_name}-${var.env_abbrev}",
    aws_lambda_function.lambda.function_name
  ])
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }

  tags = merge({
    resource = "cloudwatch"
  },
    var.tags,
    local.basic_tags
  )
}


data "archive_file" "dummy_python" {
  type        = "zip"
  source_file = "lambda_wrapper.py"
  output_path = "lambda_function.zip"
}


# A dependency on a resource with count = 0 is valid,
# because the resource block still exists even though it declares zero instances.
resource "aws_lambda_function" "lambda" {
  function_name                  = var.function_name
  description                    = var.description
  role                           = var.create_role ?
    aws_iam_role.lambda.arn :
    var.lambda_role
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.concurrency_limit
  runtime                        = var.runtime
  layers                         = var.layers
  timeout = var.timeout
  # nice to add - implement non dummy package uploads?
  filename                       = var.filename == "" ?
    data.archive_file.dummy_python.output_path :
    var.filename
  # intention is to prevent dummy file to keep overwriting
  #   actual source code that is to be updated by another
  #   ci/cd pipeline using aws cli
  source_code_hash = null

  environment {
    variables = var.environment_variables
  }

  tags = merge({
    resource = "lambda"
  },
    var.tags,
    local.basic_tags
  )

  depends_on    = [aws_cloudwatch_log_group.lambda]
}


# nice to add, there's an option for destination config on_failure/success
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventinvokeconfig.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config
resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.asynchronous ? 1 : 0

  function_name                = aws_lambda_function.lambda.function_name
  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
  maximum_retry_attempts       = var.maximum_retry_attempts
}
