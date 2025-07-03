variable "template_file" {
  type        = string
  description = "Template file name for api creation"
}

variable "region" {
  type        = string
  description = "Region of resource"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name of project"
  default     = "general"
}

# make required if env's extend
variable "env_abbrev" {
  type        = string
  description = "sbox/int/prod"
  default     = "sbox"
}

# "arn:aws:apigateway:${aws_region}:lambda:path/2015-03-31/functions/${get_lambda_arn}/invocations"
variable "lambda_arn" {
  type        = string
  description = "ARN of lambda used for backend_url"
  default     = ""
}

variable "api_gateway_name" {
  type        = string
  description = "Name of API Gateway"
}

variable "api_description" {
  type        = string
  description = "Description of API"
}

variable "backend_url" {
  type        = string
  description = "URI used to invoke backend"
  default     = ""
}

variable "stage_name" {
  type        = string
  description = "API stage name"
}

variable "iam_role_arn" {
  type        = string
  description = "IAM Role ARN used for API Gateway"
}

variable "set_lambda_permission" {
  type = bool
  default = false
}

variable "lambda_function_name" {
  type = string
  default = ""
}