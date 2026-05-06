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

variable "reasoning_engine_artefact_bucket_name" {
  description = "Name of the GCS bucket for writing the Reasoning Engine register JSON blob (e.g. my-bucket - no gs:// prefix)"
  type = string
}

variable "ephemeral_suffix" {
  type        = string
  description = "Optional ephemeral suffix to append to resource names for non-blocking development environments (e.g. dev/test)"
  default     = null
}

check "ephemeral_suffix_only_in_dev" {
  assert {
    condition     = var.environment == "dev" || var.ephemeral_suffix == null
    error_message = "The 'ephemeral_suffix' variable can only be set when the environment is 'dev'."
  }
}
