# S3 Bucket for TF State File
resource "aws_s3_bucket" "remote_tf_state" {
  bucket = var.state_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "remote_tf_state" {
  bucket = aws_s3_bucket.remote_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
#    bucket = aws_s3_bucket.terraform_state.bucket
#    rule {
#        apply_server_side_encryption_by_default {
#            sse_algorithm = "AES256"
#        }
#    }
#}

# Dynamo DB Table for Locking TF Config
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "app-state-${var.env_abbrev}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}