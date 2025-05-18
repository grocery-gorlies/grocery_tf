output "arn" {
  value       = aws_lambda_function.lambda.arn
  description = "ARN of lambda"
}

output "name" {
  value       = aws_lambda_function.lambda.function_name
  description = "Name of lambda"
}

output "role_created" {
  value = aws_iam_role.lambda.count == 0 ? false : true
}

output "iam_name" {
  value       = aws_iam_role.lambda.count == 0 ? "" : aws_iam_role.lambda.name[0]
  description = "Name of iam used by lambda"
}

output "iam_arn" {
  value       = aws_iam_role.lambda.count == 0 ? "" : aws_iam_role.lambda.arn[0]
  description = "ARN of iam used by lambda"
}