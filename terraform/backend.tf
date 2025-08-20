terraform {
  backend "s3" {
    bucket         = var.tf_state_bucket
    key            = "terraform.tfstate"
    region         = var.region
    dynamodb_table = var.tf_lock_table
    encrypt        = true
  }
}
