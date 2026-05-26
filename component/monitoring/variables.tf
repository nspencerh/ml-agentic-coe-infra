variable "location" {
  type        = string
  default     = "australia-southeast2"
  description = "BigQuery dataset location."
}

variable "deploy_service_account" {
  type        = string
  description = "Service account for deploying resources."
}
