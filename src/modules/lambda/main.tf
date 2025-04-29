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

  name               = "${var.function_name}_lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# if policies need to be attached later on
# resource "aws_iam_role_policy_attachment" "lambda_iam_s3" {
#   role       = aws_iam_role.lambda_iam.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

data "archive_file" "dummy_python" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function.zip"
}

# resource "aws_lambda_function" "lambda" {
#   filename      = "lambda_function.zip"
#   function_name = var.function_name
#   role          = aws_iam_role.lambda_iam.arn
#
#   handler       = "index.lambda_handler"
#   runtime = "python3.12"
#
#   source_code_hash = null
#
#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }

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
}


# nice to add, there's an option for destination config on_failure/success
resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.asynchronous ? 1 : 0

  function_name                = aws_lambda_function.lambda.function_name
  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
  maximum_retry_attempts       = var.maximum_retry_attempts
}

