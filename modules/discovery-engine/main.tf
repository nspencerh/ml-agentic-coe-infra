resource "google_discovery_engine_chat_engine" "this" {
  project        = var.project_id
  location       = var.location
  engine_id      = var.engine_id
  display_name   = var.display_name
  collection_id  = var.collection_id
  data_store_ids = var.data_store_ids

  industry_vertical = var.industry_vertical

  chat_engine_config {
    agent_creation_config {
      business              = var.display_name
      default_language_code = var.default_language_code
      time_zone             = var.time_zone
      location              = var.location
    }
  }

  dynamic "common_config" {
    for_each = var.company_name != "" ? [var.company_name] : []
    content {
      company_name = common_config.value
    }
  }
}