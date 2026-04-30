module "reasoning_engines" {
  source = "../../../modules/reasoning-engines"

  project_id          = var.project_id
  region              = var.region
  engine_id           = var.gemini_app.engine_id
  reasoning_engines   = var.reasoning_engines
  outputs_bucket      = var.outputs_bucket
  outputs_component   = "gemini"
  outputs_environment = var.environment
}