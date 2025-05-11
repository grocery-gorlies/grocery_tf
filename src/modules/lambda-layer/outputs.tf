output "arn" {
  value       = aws_lambda_layer_version.lambda_layer.arn
  description = "ARN of layer with version"
}

output "layer_arn" {
  value       = aws_lambda_layer_version.lambda_layer.layer_arn
  description = "ARN of layer without version attached"
}

output "name" {
  value       = aws_lambda_layer_version.lambda_layer.layer_name
  description = "Name of layer"
}

output "version" {
  value       = aws_lambda_layer_version.lambda_layer.version
  description = "Layer version"
}