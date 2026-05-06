variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us"
}

# variable "build_project_id" {
#   type        = string
#   description = "The GCP project ID used for build and CI/CD artifacts"
# }

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "environment_suffix" {
  type        = string
  default     = null
  description = "Optional suffix for resource IDs (used by feature branch deployments to avoid collisions). Leave empty for preprod/prod."
}
