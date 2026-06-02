variable "location" {
  type        = string
  default     = "us"
  description = "GCP location."
}

variable "deploy_service_account" {
  type        = string
  description = "Service account for deploying resources."
}

variable "alert_notification_email" {
  description = "Email address for alert notifications"
  type        = string
}
