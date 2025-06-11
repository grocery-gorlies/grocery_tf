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

variable "role_name" {
  type = string
  description = "name for IAM role"
}

variable "entity_type" {
  type        = string
  description = "Type of identifiers to specify for assuming this role (AWS/Service)"
}

variable "identifiers" {
  type = list(string)
  description = "List of entities allowed to assume this role"
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

variable "attach_basic_cloudwatch_policy" {
  type = bool
  default = false
}

variable "resource_type" {
  type        = string
  description = "resource type to create iam role and policy for"
}

variable "resource_name" {
  type        = string
  description = "specific name of the resource iam is being created for"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags for lambda"
  default     = {}
}