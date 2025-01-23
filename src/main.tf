module "tf-state-sbox" {
    source = "./modules/tf_state"
    bucket_name = "${var.state_bucket_name}-${var.env_abbrev}"
}