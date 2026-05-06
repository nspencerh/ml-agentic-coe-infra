data google_storage_bucket artefact_bucket {
  name = var.reasoning_engine_artefact_bucket_name
}

module "reasoning_engines" {
  source = "../../modules/reasoning-engines"

  project_id          = var.project_id
  region              = var.region
  engine_id           = var.gemini_app.engine_id
  reasoning_engines   = var.reasoning_engines
  register_bucket      = data.google_storage_bucket.artefact_bucket.url
  register_environment = var.environment
}
