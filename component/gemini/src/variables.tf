variable "gemini_app" {
  description = "Configuration for the Gemini Enterprise (Discovery Engine) app"
  type = object({
    engine_id             = string
    display_name          = string
    location              = optional(string, "global")
    collection_id         = optional(string, "default_collection")
    data_store_ids        = list(string)
    industry_vertical     = optional(string, "GENERIC")
    default_language_code = optional(string, "en")
    time_zone             = optional(string, "Australia/Sydney")
    company_name          = optional(string, "")
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