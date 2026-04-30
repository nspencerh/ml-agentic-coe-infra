module "discovery_engine" {
  source = "../../../modules/discovery-engine"

  project_id            = var.project_id
  engine_id             = var.gemini_app.engine_id
  display_name          = var.gemini_app.display_name
  location              = var.gemini_app.location
  collection_id         = var.gemini_app.collection_id
  data_store_ids        = var.gemini_app.data_store_ids
  industry_vertical     = var.gemini_app.industry_vertical
  default_language_code = var.gemini_app.default_language_code
  time_zone             = var.gemini_app.time_zone
  company_name          = var.gemini_app.company_name
}