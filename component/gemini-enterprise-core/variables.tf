variable "gemini_app" {
  description = "Configuration for the Gemini Enterprise (Discovery Engine) app"
  type = object({
    engine_id             = string
    display_name          = string
    location              = optional(string, "global")
    collection_id         = optional(string, "default_collection")
    data_store_ids        = optional(list(string), [])
    industry_vertical     = optional(string, "GENERIC")
    default_language_code = optional(string, "en")
    time_zone             = optional(string, "Australia/Melbourne")
    company_name          = optional(string, "Transurban")
  })
}

variable "reasoning_engines" {
  description = "Map of Reasoning Engine shells to create"
  type = map(object({
    display_name = string
    description  = optional(string, "")
    package_spec = optional(object({
      pickle_object_gcs_uri    = optional(string)
      dependency_files_gcs_uri = optional(string)
      requirements_gcs_uri     = optional(string)
      python_version           = optional(string)
    }))
  }))
  default = {}
}

variable "registry_bucket" {
  description = "Name of the GCS bucket for writing the Reasoning Engine registry JSON blob (e.g. my-bucket - no gs:// prefix)"
  type        = string
}

check "ephemeral_suffix_only_in_discovery" {
  assert {
    condition     = var.environment == "discovery" || var.ephemeral_suffix == null
    error_message = "The 'ephemeral_suffix' variable can only be set when the environment is 'discovery'."
  }
}

variable "deploy_service_account" {
  type        = string
  description = "Service account for deploying resources."
}
