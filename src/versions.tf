terraform {
    required_version = ">=1.10.1"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>5.80.0"
        }
    }
    backend "s3" {
        bucket = "ggtfstate"
        key = "dev/aws_infrastructure"
        region = "us-east-1"
        dynamodb_table = "app-state"
        encrypt = true
  }
}

provider "aws" {
    region = "us-east-1"
}