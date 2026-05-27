variable "location" {
  type        = string
  default     = "us"
  description = "GCP location."
}

variable "deploy_service_account" {
  type        = string
  description = "Service account for deploying resources."
}
