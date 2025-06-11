resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = "/${var.project_name}-${var.env_abbrev}/"

  tags = merge({
    resource = "iam"
  },
    var.tags
  )
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = var.entity_type
      identifiers = var.identifiers
    }
  }
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

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = compact([
      var.attach_basic_s3_policy == true ? data.aws_iam_policy_document.s3.json : "",
      var.attach_basic_cloudwatch_policy == true ? data.aws_iam_policy_document.cloudwatch.json : "",
  ])
}

resource "aws_iam_policy" combined {
  count = (
    var.attach_basic_s3_policy ||
    var.attach_basic_cloudwatch_policy
  ) ? 0 : 1

  name        = "combined-${aws_iam_role.this.name}-policy"
  description = "combined policy for ${var.resource_type} ${var.resource_name}"
  policy      = data.aws_iam_policy_document.combined.json
  path        = "/${var.project_name}-${var.env_abbrev}/"
}


resource "aws_iam_role_policy_attachment" "combined"{
  count = length(aws_iam_policy.combined)

  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.combined[0].arn
}