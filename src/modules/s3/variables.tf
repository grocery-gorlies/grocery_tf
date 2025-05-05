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

variable "bucket_name" {
  type        = string
  description = "Name of s3 bucket. Project name and env added automatically"
  default     = ""
}

variable "bucket_expiration_days" {
  type        = number
  description = "Number of days in which to expire objects in bucket"
  default     = -1
}

variable "attach_bucket_policies" {
  type = bool
  description = "Set to true if additional bucket policies need to be attached"
  default = false
}

variable "attach_account_access" {
  type = bool
  description = "Attaches access policy for accounts specified in 'other_accounts'"
  default = false
}

variable "other_accounts" {
  type = list(string)
  description = "List of other accounts to allow bucket access"
  default = []
}

variable "tags" {
  type = map(string)
  description = "Map of tags for s3 bucket"
  default = {}
}