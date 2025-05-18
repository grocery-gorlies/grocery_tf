output "arn" {
  value       = aws_lambda_function.lambda.arn
  description = "ARN of lambda"
}

output "name" {
  value       = aws_lambda_function.lambda.function_name
  description = "Name of lambda"
}

output "iam_name" {
  value       = aws_iam_role.lambda.name
  description = "Name of iam used by lambda"
}

output "iam_arn" {
  value       = aws_iam_role.lambda.arn
  description = "ARN of iam used by lambda"
}