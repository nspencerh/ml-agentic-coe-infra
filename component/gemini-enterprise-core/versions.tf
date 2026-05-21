terraform {
  required_version = ">= 1.9"
  
  backend "gcs" {}
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.30"
    }
  }
}

provider "google" {
  impersonate_service_account = var.deploy_service_account
  project                     = var.project_id
}