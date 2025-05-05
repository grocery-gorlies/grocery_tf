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

# make required if regions extend
variable "region" {
  type        = string
  description = "Region of resource"
  default     = "us-east-1"
}

variable "region_abbrev" {
  type        = string
  description = "Abbreviated region of resource"
  default     = "ue1"
}

variable "create_role" {
  type    = bool
  default = true
}

variable "attach_basic_s3_policy" {
  type = bool
  default = false
}

variable "used_s3_resources" {
  type = list(string)
  description = "List of s3 list arn's lambda needs access to"
  default = ["*"]
}

variable "function_name" {
  type = string
}

variable "description" {
  type        = string
  description = "Lambda description"
  default     = ""
}

variable "lambda_role" {
  type        = string
  description = "IAM role ARN to be used for lambda function"
  default     = ""
}

variable "handler" {
  type        = string
  description = "Entry point for lambda"
  default     = "lambda_wrapper.lambda_handler"
}

variable "memory_size" {
  type        = number
  description = "Memory in MB your Lambda can use at runtime. (128 to 10240)"
  default     = 128
}

variable "concurrency_limit" {
  type        = number
  description = "Limit on how many lambdas can run concurrently. -1 is unlimited, 0 prevents any runs"
  default     = 1
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "layers" {
  type        = list(string)
  description = "Lambda Layer ARNs to include - max 5"
  default     = null
}

variable "timeout" {
  type        = number
  description = "In seconds, how long your Lambda can run - 900 (15 min) is max"
  default     = 3
}

variable "filename" {
  type        = string
  description = "Path to the function's deployment package within the local filesystem"
  default     = ""
}

variable "environment_variables" {
  type        = map(string)
  description = "Map of environmental variables for lambda"
  default     = {}
}

variable "asynchronous" {
  type        = string
  description = "Set to true for Lambda retries"
}

variable "maximum_event_age_in_seconds" {
  type        = number
  description = "Controls lifespan of event in Lambda queue in seconds - 60 to 21600(6 hours)"
  default     = 60
}

variable "maximum_retry_attempts" {
  type        = number
  description = "Max number of retries - 0 to 2"
  default     = 2
}

variable "tags" {
  type        = map(string)
  description = "Map of tags for lambda"
  default     = {}
}