locals {
  basic_tags = {
    region      = var.region,
    environment = var.env_abbrev,
    project     = var.project_name
    function    = var.function_name
  }

  function_name = "${var.function_name}-${var.env_abbrev}"
  dummy_file_path = "${path.cwd}/modules/lambda/lambda_wrapper.py"
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

  name               = "${local.function_name}-lambda-iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  tags = merge({
    resource = "iam"
  },
    var.tags,
    local.basic_tags
  )
}


resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.create_role ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_cloudwatch_log_group" "lambda" {
  name = join("/", [
    "/lambda",
    var.region,
    "${var.project_name}-${var.env_abbrev}",
    local.function_name
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


data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = var.used_s3_resources
  }

  statement {
    effect = "Deny"
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::ggstate"]
  }
}


data "aws_iam_policy_document" "combined" {
  # count = var.create_role && (var.policy1_enabled || var.policy2_enabled) ? 1 : 0
  count = var.create_role && var.attach_basic_s3_policy ? 1 : 0
  source_policy_documents = compact([
      var.attach_basic_s3_policy == true ? data.aws_iam_policy_document.s3.json : "",
      # var.policy2_enable == true ? data.aws_iam_policy_document.policy2.json : "",
  ])
}


resource "aws_iam_policy" combined {
  # count = var.create_role && (var.policy1_enabled || var.policy2_enabled) ? 1 : 0
  count = var.create_role && var.attach_basic_s3_policy ? 1 : 0
  name = "combined-${local.function_name}"
  description = "combined policy for lambda ${local.function_name}"
  policy = data.aws_iam_policy_document.combined[0].json
}


resource "aws_iam_role_policy_attachment" "combined"{
  # count = var.create_role && (var.policy1_enabled || var.policy2_enabled) ? 1 : 0
  count = var.create_role && var.attach_basic_s3_policy ? 1 : 0
  role = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.combined[0].arn
}


data "archive_file" "dummy_python" {
  type        = "zip"
  source_file = local.dummy_file_path
  output_path = "lambda_function.zip"
}


# A dependency on a resource with count = 0 is valid,
# because the resource block still exists even though it declares zero instances.
resource "aws_lambda_function" "lambda" {
  function_name                  = local.function_name
  description                    = var.description
  role                           = var.create_role ? (
  aws_iam_role.lambda[0].arn
  ) : (
  var.lambda_role
  )
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.concurrency_limit
  runtime                        = var.runtime
  layers                         = var.layers
  timeout = var.timeout
  # nice to add - implement non dummy package uploads?
  filename                       = var.filename == "" ? (
  data.archive_file.dummy_python.output_path
  ) : (
  var.filename
  )
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
