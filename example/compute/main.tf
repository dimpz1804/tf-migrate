terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

  backend "s3" {
    key = "learn-terraform-migrate/compute/frontend/terraform.tfstate"
  }
}

resource "random_string" "this" {
  count  = var.string_count
  length = var.string_length
}