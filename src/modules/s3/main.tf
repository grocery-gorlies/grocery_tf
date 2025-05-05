locals {
  proper_bucket_name = var.bucket_name == "" ? (
  "${var.project_name}-${var.env_abbrev}-${var.region_abbrev}"
  ): (
  "${var.project_name}-${var.bucket_name}-${var.env_abbrev}-${var.region_abbrev}"
  )

  basic_tags = {
    region      = var.region,
    environment = var.env_abbrev,
    project     = var.project_name
    name        = local.proper_bucket_name
  }
}

resource "aws_s3_bucket" "this" {
  bucket = local.proper_bucket_name
  tags = merge({
    resource = "s3"
  },
    var.tags,
    local.basic_tags
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.bucket_expiration_days == -1 ? 0 : 1

  bucket = aws_s3_bucket.this.id
  rule {
    status = "Enabled"
    id     = "expire_all_files"
    expiration {
        days = var.bucket_expiration_days
    }
  }
}

data "aws_iam_policy_document" "account_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = var.other_accounts
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "combined" {
  # count = var.create_role && (var.policy1_enabled || var.policy2_enabled) ? 1 : 0
  count = var.attach_bucket_policies && var.attach_account_access ? 1 : 0
  source_policy_documents = compact([
      var.attach_account_access == true ? data.aws_iam_policy_document.account_access.json : "",
      # var.policy2_enable == true ? data.aws_iam_policy_document.policy2.json : "",
  ])
}

resource "aws_s3_bucket_policy" "combined" {
  count = var.attach_bucket_policies ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined[0].json
}