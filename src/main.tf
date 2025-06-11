module "tf-state" {
  source            = "./modules/tf-state"
  state_bucket_name = var.state_bucket_name
  env_abbrev        = var.env_abbrev
}

module "gg-s3-bucket" {
  source = "./modules/s3"

  project_name = var.gg_project_name
  env_abbrev = var.env_abbrev
  region = var.us-east-1
  region_abbrev = var.ue1
}

module "default-py-layer" {
  source = "./modules/lambda-layer"

  project_name  = var.gg_project_name
  env_abbrev    = var.env_abbrev
  region_abbrev = var.ue1

  requirements_file = "default-py.txt"
  layer_name        = "default-py"
  layer_bucket      = module.gg-s3-bucket.bucket_id
  compatible_runtimes = ["python3.12"]
}

module "input-handler-lambda" {
  source = "./modules/lambda"

  project_name  = var.gg_project_name
  env_abbrev    = var.env_abbrev
  region        = var.us-east-1
  region_abbrev = var.ue1

  attach_basic_s3_policy = true
  used_s3_resources = ["${module.gg-s3-bucket.bucket_arn}/*"]

  function_name = "input-handler"
  description   = "Handles input from users."
  create_role   = true
  layers = ["${module.default-py-layer.layer_arn}:1"]

  environment_variables = {
    RECEIPT_BUCKET = module.gg-s3-bucket.bucket_id
  }
  asynchronous = true
}

module "input-handler-apigateway-iam" {
  source                         = "./modules/iam"
  project_name                   = var.gg_project_name
  env_abbrev                     = var.env_abbrev
  region                         = var.us-east-1
  entity_type                    = "Service"
  identifiers = ["apigateway.amazonaws.com"]
  role_name                      = "input-handler-apigateway-iam"
  attach_basic_cloudwatch_policy = true
  resource_type                  = "API Gateway"
  resource_name                  = "input-handler-api"
}

module "input-handler-api-gateway" {
  source           = "./modules/api-gateway-openapi"
  template_file    = "./modules/api-gateway-openapi/templates/input-handler.json"
  project_name     = var.gg_project_name
  env_abbrev       = var.env_abbrev
  region           = var.us-east-1
  lambda_arn       = module.input-handler-lambda.arn
  api_gateway_name = "input-handler-api"
  api_description  = "API to handle Grocery Gorlies entries"
  stage_name       = "gg-dev"
  iam_role_arn     = module.input-handler-apigateway-iam.created_iam_arn
}

#todo: add cloudwatch? and also tags