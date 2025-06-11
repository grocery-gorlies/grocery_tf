output "created_iam_name" {
  value       = aws_iam_role.this.name
  description = "Name of iam"
}

output "created_iam_arn" {
  value       = aws_iam_role.this.arn
  description = "ARN of iam"
}