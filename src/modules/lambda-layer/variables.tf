variable "project_name" {
  type        = string
  description = "Name of project"
  default     = "general"
}

variable "env_abbrev" {
  type        = string
  description = "sbox/int/prod"
  default     = "sbox"
}

variable "region_abbrev" {
  type        = string
  description = "Abbreviated region of resource"
  default     = "ue1"
}

variable "layer_name" {
  type        = string
  description = "Name of layer zip file"
  default     = "default-py"
}

variable "requirements_file" {
  type        = string
  description = "Name of file to create layer zip from"
  default     = "requirements.txt"
}

variable "requirements_path" {
  type        = string
  description = "Path of file to create layer zip from.  Empty string assumes file in default requirements directory"
  default     = ""
}

variable "layer_bucket" {
  type        = string
  description = "ID of bucket to save layer source code"
  default     = ""
}

variable "layer_s3_prefix" {
  type        = string
  description = "Name of s3 bucket to put lambda layer zip in"
  default     = "lambdalayers"
}

variable "compatible_runtimes" {
  type = list(string)
  description = "List of compatible runtimes for layer"
  default = ["python3.12"]
}