variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us"
}

variable "build_project_id" {
  type        = string
  description = "The GCP project ID used for build and CI/CD artifacts"
}

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "outputs_bucket" {
  type        = string
  description = "GCS bucket for writing outputs blobs consumed by agent CI/CD"
}