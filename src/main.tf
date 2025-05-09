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