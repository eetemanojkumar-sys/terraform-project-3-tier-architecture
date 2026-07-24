terraform {
  backend "s3" {
    bucket       = "manoj-terraform-state-2026-710959681253-ap-south-1-an"
    key          = "3-tier/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
