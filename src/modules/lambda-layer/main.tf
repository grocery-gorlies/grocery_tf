locals {
  requirements_full_path = var.requirements_path == "" ?
    "${path.cwd}/requirements/${var.requirements_file}" :
    var.requirements_path
  layer_zip_name = "${var.layer_name}.zip"
  log1 = "creating layer from ${local.requirements_full_path}"
  log2 = "running pip install for ${var.requirements_file}"
  log3 = "Error: ${local.requirements_full_path} does not exist!"
}

# used to be null_resource with triggers = { requirements = ...}
# create zip file from requirements file. Triggers only when the file is updated
resource "terraform_data" "lambda_layer" {
  triggers_replace = [filesha1(local.requirements_full_path)]

  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
        echo ${local.log1}
        rm -rf layer
        mkdir layer

        # Installing python dependencies...
        if [ -f ${local.requirements_full_path} ]; then
            echo ${local.log2}
            pip install -r ${local.requirements_full_path} -t layer/
            zip -r ${local.layer_zip_name} layer/
        else
            echo ${local.log3}
        fi

        #deleting the python dist package modules
        rm -rf layer

    EOT
  }
}

# todo - is this redundant?
data "aws_s3_bucket" "selected" {
  bucket = var.layer_bucket != "" ? var.layer_bucket : (
  "${var.project_name}-${var.env_abbrev}-${var.region_abbrev}"
  )
}

# upload zip file to s3
resource "aws_s3_object" "lambda_layer_zip" {
  bucket     = data.aws_s3_bucket.selected.id
  key        = "${var.layer_s3_prefix}/${var.layer_name}/${local.layer_zip_name}"
  source     = local.layer_zip_name
  depends_on = [terraform_data.lambda_layer] # triggered only if the zip file is created
}

# create lambda layer from s3 object
resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket           = data.aws_s3_bucket.selected.id
  s3_key              = aws_s3_object.lambda_layer_zip.key
  layer_name          = var.layer_name
  compatible_runtimes = var.compatible_runtimes
  skip_destroy        = true
  depends_on          = [aws_s3_object.lambda_layer_zip] # triggered only if the zip file is uploaded to the bucket
}