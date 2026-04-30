terraform {
  backend "gcs" {
  }

  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.30"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where monitoring resources will be deployed."
}

variable "region" {
  type        = string
  description = "The GCP region."
}

variable "environment" {
  type        = string
  description = "The environment name."
}