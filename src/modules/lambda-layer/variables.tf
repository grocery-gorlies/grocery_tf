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

variable "compatible_runtimes" {
  type = list(string)
  description = "List of compatible runtimes for layer"
  default = ["python3.12"]
}

variable "layer_s3_prefix" {
  type        = string
  description = "Name of s3 bucket to put lambda layer zip in"
  default     = "lambdalayers"
}