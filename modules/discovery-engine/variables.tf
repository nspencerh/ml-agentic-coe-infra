variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "engine_id" {
  type        = string
  description = "The Discovery Engine app ID"
}

variable "display_name" {
  type        = string
  description = "Human-readable display name for the engine"
}

variable "location" {
  type        = string
  default     = "global"
  description = "Location for the Discovery Engine app (global, us, eu)"
}

variable "collection_id" {
  type        = string
  default     = "default_collection"
  description = "The collection ID"
}

variable "data_store_ids" {
  type        = list(string)
  description = "Data store IDs associated with the engine"
}

variable "industry_vertical" {
  type        = string
  default     = "GENERIC"
  description = "Industry vertical (GENERIC)"
}

variable "default_language_code" {
  type        = string
  default     = "en"
  description = "Default language code for the agent (e.g. en, fr, de)"
}

variable "time_zone" {
  type        = string
  default     = "Australia/Sydney"
  description = "Time zone for the agent (IANA time zone database format)"
}

variable "company_name" {
  type        = string
  default     = ""
  description = "Company name for common config (optional)"
}