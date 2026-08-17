terraform {
  backend "s3" {
    bucket = "order-management-terraform-state-303989461773"
    key    = "order-management/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}