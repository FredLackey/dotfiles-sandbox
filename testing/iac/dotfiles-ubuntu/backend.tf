terraform {
  backend "s3" {
    bucket         = "tfstate-ses-dotfiles-sandbox"
    key            = "dotfiles-ubuntu/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-ses-dotfiles-sandbox-locks"
    encrypt        = true
    profile        = "bh-fred-sandbox"
  }
}
