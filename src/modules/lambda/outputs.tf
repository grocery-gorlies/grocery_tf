output "arn" {
  value       = aws_lambda_function.lambda.arn
  description = "ARN of lambda"
}

output "name" {
  value       = aws_lambda_function.lambda.function_name
  description = "Name of lambda"
}

output "role_created" {
  value = var.create_role
}

output "created_iam_name" {
  value       = var.create_role ? aws_iam_role.lambda[0].name : ""
  description = "Name of iam used by lambda"
}

output "created_iam_arn" {
  value       = var.create_role ? aws_iam_role.lambda[0].arn : ""
  description = "ARN of iam used by lambda"
}