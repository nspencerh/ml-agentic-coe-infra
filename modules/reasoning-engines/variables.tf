variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for the Reasoning Engines"
}

variable "engine_id" {
  type        = string
  description = "The Discovery Engine app ID (included in the GCS outputs blob)"
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

variable "outputs_bucket" {
  type        = string
  description = "GCS bucket for writing the outputs blob"
}

variable "outputs_component" {
  type        = string
  description = "Component name used in the GCS outputs path"
}

variable "outputs_environment" {
  type        = string
  description = "Environment name used in the GCS outputs path"
}