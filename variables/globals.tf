variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us"
}

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "ephemeral_suffix" {
  type        = string
  default     = null
  description = "Optional suffix for resource IDs (used by feature branch deployments to avoid collisions). Leave empty for preprod/prod."
}
