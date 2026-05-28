variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-central1"
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

# Defines which environments this configuration will deploy resources to.
# if resource/module has a:
# count = (local.deploy_discovery || local.deploy_us) ? 1 : 0 -> resources will be deployed to ephemeral, discovery, preprod-us and prod-us environments.
# count = (local.deploy_discovery || local.deploy_au) ? 1 : 0 -> resources will be deployed to ephemeral, discovery, preprod-au and prod-au environments.
# count = (local.deploy_discovery || local.deploy_au || local.deploy_us) ? 1 : 0 -> resources will be deployed to all environments.
locals {
  deploy_discovery = (
    var.environment == "discovery" ||
    can(regex("^pr-[0-9]+$", var.environment))
  )
  deploy_au        = contains(["preprod-au", "prod-au"], var.environment)
  deploy_us        = contains(["preprod-us", "prod-us"], var.environment)
}