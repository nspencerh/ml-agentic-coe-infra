resource "google_vertex_ai_reasoning_engine" "engines" {
  for_each = var.reasoning_engines

  project      = var.project_id
  region       = var.region
  display_name = each.value.display_name
  description  = each.value.description

  dynamic "spec" {
    for_each = each.value.package_spec != null ? [each.value.package_spec] : []
    content {
      package_spec {
        pickle_object_gcs_uri    = spec.value.pickle_object_gcs_uri
        dependency_files_gcs_uri = spec.value.dependency_files_gcs_uri
        requirements_gcs_uri     = spec.value.requirements_gcs_uri
        python_version           = spec.value.python_version
      }
    }
  }
}

locals {
  outputs_blob = jsonencode({
    engine_id  = var.engine_id
    project_id = var.project_id
    location   = var.region
    reasoning_engines = {
      for key, engine in google_vertex_ai_reasoning_engine.engines : key => {
        id           = engine.id
        name         = engine.name
        display_name = engine.display_name
      }
    }
  })
}

resource "google_storage_bucket_object" "outputs" {
  bucket  = var.outputs_bucket
  name    = "outputs/${var.outputs_component}/${var.outputs_environment}/gemini-outputs.json"
  content = local.outputs_blob

  content_type = "application/json"
}